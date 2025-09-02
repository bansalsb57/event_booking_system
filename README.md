## Event Booking System
## This is an Event Booking System built with Ruby on Rails, utilizing Sidekiq for background job processing and Redis for job queuing.
## Project Overview
## The Event Booking System is a Rails-based application that allows users to create and manage events, purchase tickets, and track bookings. The application supports different user roles, including event organizers and customers.

## Project Setup

## Make sure you have the following installed:

Ruby (3.3.0)

Rails (8.0.2)

PostgreSQL

Redis (for Sidekiq job processing)

## Clone the Repository
git clone git@github.com:bansalsb57/event_booking_system.git
cd event_booking_system
bundle install
rails db:create db:migrate db:seed

## Start Redis Server
redis-server
## Start Sidekiq
bundle exec sidekiq
## Start the Rails Server
rails s

## Your application should now be running at http://localhost:3000/.

## Background Jobs
## Booking Confirmation Job
## This job sends a confirmation message when a ticket is booked.
## Event Update Notification Job
## This job notifies customers when an event is updated.

## Postman collection

## Contributor
## Prakash Chand
