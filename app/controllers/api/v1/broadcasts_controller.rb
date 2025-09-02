# app/controllers/api/v1/broadcasts_controller.rb
module Api
  module V1
    class BroadcastsController < ApplicationController

      require 'fileutils'

      ICECAST_URL = "icecast://source:hackmesource@localhost:8000/stream.mp3"
      TMP_AUDIO_PATH = Rails.root.join('tmp', 'audio')
      TMP_AUDIO_FILE = TMP_AUDIO_PATH.join('audio.mp3')

      def create
        # Ensure temp directory exists
        FileUtils.mkdir_p(TMP_AUDIO_PATH)

        # Get audio file
        audio_file = params[:audio_file]

        unless audio_file
          return render json: { error: "Audio file is required" }, status: :unprocessable_entity
        end

        # Save the MP3 audio file directly
        File.open(TMP_AUDIO_FILE, 'wb') { |file| file.write(audio_file.read) }

        render json: { message: "Audio file uploaded successfully" }
      end

      def start
        # Check if MP3 file exists
        unless File.exist?(TMP_AUDIO_FILE)
          return render json: { error: "No audio file available to stream" }, status: :unprocessable_entity
        end

        # Extract audio details
        audio_details = extract_audio_details(TMP_AUDIO_FILE)

        # Terminate existing stream process (if any)
        system("pkill -f 'ffmpeg -re -i #{TMP_AUDIO_FILE}'")

        # FFmpeg command to re-encode and stream
        ffmpeg_command = <<~CMD
          ffmpeg -re -i #{TMP_AUDIO_FILE} \
          -map 0:a -c:a libmp3lame -b:a 32k -ar 44100 -f mp3 \
          #{ICECAST_URL}
        CMD

        # Start FFmpeg streaming
        pid = spawn(ffmpeg_command)
        Process.detach(pid)

        # Construct response
        render json: { 
          message: "Broadcast started successfully at 32 kbps", 
          stream_url: "http://localhost:8000/stream.mp3",
          audio_details: audio_details
        }
      end

      def stop
        # Terminate all running FFmpeg processes
        system("pkill -f 'ffmpeg -re -i #{TMP_AUDIO_FILE}'")

        render json: { message: "Broadcast stopped successfully" }
      end

      def extract_audio_details(file_path)
        command = %Q(ffprobe -v quiet -print_format json -show_format -show_streams "#{file_path}")
        output = `#{command}`
        JSON.parse(output)
      rescue => e
        Rails.logger.error("FFprobe Error: #{e.message}")
        {}
      end
    end
  end
end
