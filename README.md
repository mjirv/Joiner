# JOINER

Joiner is a web application that sets up and manages [JoinDB](https://github.com/mjirv/JoinDb) data warehouses in the cloud. Data analysts can easily set up a data warehouse to join multiple data sources in one database and add all their data instead of having to build the databases themselves or hire an engineer or consultant.

## Setup

### 1. Install pgfutter
Joiner uses a tool called [pgfutter](https://github.com/lukasmartinelli/pgfutter) to copy CSVs into a Postgres database. Install as appropriate on your system following the linked instructions. Set the `PGFUTTER` environment variable to the correct path depending on where you installed it.

### 2. Production
Joiner is deployed in production on Heroku using a Postgres database. Just deploy from this repository with the following environment variables:

|ENV                     |Suggested default value                            |
|------------------------|---------------------------------------------------|
|AWS_ACCESS_KEY          | _secret_                                          |
|AWS_REGION              | us-east-1                                         |
|AWS_SECRET_ACCESS_KEY   |_secret_                                           |
|BETA_USER_LIMIT         |0 (delete if you want sign-ups publicly available) |
|DATABASE_URL            |Heroku fills this out for you                      |
|LANG                    |Heroku defaults to en_US.UTF-8                     |
|MAIL_PASSWORD           |_secret_                                           |
|PGFUTTER                |/app/lib/pgfutter (wherever you installed pgfutter)|
|RACK_ENV                |production                                         |
|RAILS_ENV               |production                                         |
|RAILS_LOG_TO_STDOUT     |enabled                                            |
|RAILS_SERVE_STATIC_FILES|enabled                                            |
|SECRET_KEY_BASE         |_secret_                                           |

You may need to run `budle exec rake db:migrate` via the Heroku console.

### 3. Development
It's a typical Rails app. Deploy with `bundle exec rails s`, and modify the environment variables above appropriately.
