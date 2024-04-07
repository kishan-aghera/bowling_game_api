# Bowling Game API

## Table Of Contents

* [About the Project](#about-the-project)
* [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Testing](#testing)

## About The Project

This repo contains API using which you can calculate score for a bowling game.

## Built With

- Ruby 3.3.0
- Sinatra for API server
- Rspec for testing

## Getting Started

### Prerequisites

* ruby (Make sure rbenv is installed. Please refer [rbenv](https://github.com/rbenv/rbenv?tab=readme-ov-file) if not.)

```sh
rbenv install 3.3.0
```

### Installation

1. Clone the repo

```sh
git clone https://github.com/kishan-aghera/bowling_game_api.git 
```

2. Move into the bowling_game_api directory.

```sh
cd bowling_game_api
```

3. Bundle the required gems

```sh
bundle install
```

4. Start the sinatra server

```sh
ruby server.rb
```

## Usage

### Using Postman/Thunder Client:

- There are 3 APIs that are created: 

#### POST /start

- This will initialize an object of the BowlingGame class.

#### POST /roll

- This is used to add roll and update the score.
- We will need to pass `pins` key with the no. of pins fallen as integer like `5`. So, pass parameters in body in JSON format like:

```json
{
  "pins": 5
}
```

- This should give response like shown below.

```json
{
  "message": "Roll successful.",
  "current_score": [
    {
      "rolls": [
        5
      ],
      "score": 5
    }
  ],
  "total_score": 5,
  "last_frame": "none"
}
```

#### GET /current_score

- This will give output something like shown below.

```json
{
  "message": "Success",
  "current_score": 5,
  "total_score": 5,
  "last_frame": "none"
}
```

###  Using IRB:

1. Run IRB from within the project's directory.

```sh
irb
```

2. Require the `bowling_game` rb class.

```ruby
require_relative "./bowling_game"
```

3. Initialize the class.

```ruby
game = BowlingGame.new
```
4. There are various methods available that you can use. e.g.

i. To roll a pin let's say 5, use 

```ruby
game.roll(5)
```

ii. To get current score, use

```ruby
game.current_score
```

This should return

```ruby
5
```

iii. To get total score, use:

```ruby
game.total_score
```

This should return

```ruby
5
```

## Testing

- Rspec is used for testing this API as well as the class.
- In order to run all the spec files at once, please run 

```sh
rspec
```

- In order to run spec file for API, run

```sh
rspec spec/bowling_api_spec.rb
```

- In order to run spec file for the Bowling Game class, run

```sh
rspec spec/bowling_game_spec.rb
```

