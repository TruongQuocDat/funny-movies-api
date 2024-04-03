# README

## FUNNY MOVIES API

### Introduction

The funny-movies-api project is a Ruby on Rails-based application designed to share and enjoy youtube clips. This API 
allows users to submit links to funny videos, view a curated list of video content. Our goal is to create a 
community-driven platform where humor is easily accessible and shared.

### Prerequisites

To run this project, you will need:

* Ruby, version 3.2.2
* Rails, version 7.0.8.1
* PostgreSQL
* Node.js (for Webpacker)

### Installation & Configuration
**Cloning the Repository**
```
git clone https://github.com/TruongQuocDat/funny-movies-api.git
cd funny-movies-api
```
**Installing Dependencies**

Install Ruby gems:
```
bundle install
```
**Configuring Settings**

Create a .env file based on .env.sample provided, and customize your environment variables:
```
cp .env.sample .env
```
Add ENV['YOUTUBE_API_KEY'] value to file .env to make sure fetch data from youtube success

**Database Setup**

Ensure PostgreSQL is running, then create and set up the database:
```
rails db:create db:migrate
```

### Running the Application
**Starting the Development Server**

At here I decide choose port `3001` to start rails server. But you can change it if you want another port. 
(avoid conflict with a React frontend running on `3000`)
```
rails server -p 3001
```

**Accessing the Application**

Navigate to http://localhost:3001 in your browser to access the API endpoints.

**Running the Test Suite**

Execute the following command to run the automated tests:
```
bundle exec rspec
```

## Usage
The API supports the following operations:

* POST /api/v1/videos: Submit a new funny movie link.
* GET /api/v1/videos: Retrieve a list of all shared funny movies.
Use tools like Postman or curl to interact with the API endpoints.
