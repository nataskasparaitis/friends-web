# Friends

A small contact manager built with Ruby on Rails 8. You sign up, sign in, and
keep your own list of friends with their contact details.

## What it does today

- Sign up, sign in, sign out, edit your profile, reset a forgotten password (Devise)
- Full CRUD on friends: list, view, add, edit, delete
- Every friend belongs to the user who created it, and only that user can see,
  edit, or delete it
- Validation on names and email, with errors shown above the form
- Navbar search across name, email, phone, and Twitter handle
- Bootstrap 5 navigation, tables, and dismissible flash messages
- JSON responses for the friends endpoints via Jbuilder
- Two static pages, `/home/index` and `/home/about`

Signing in lands you on `/`, which is the friends list.

## Stack

| Layer | Choice |
|---|---|
| Language | Ruby 4.0.6 (pinned in `.ruby-version`) |
| Framework | Rails 8.1.3.1 |
| Database | SQLite 3 |
| Web server | Puma |
| Authentication | Devise 5 |
| Assets | Propshaft |
| JavaScript | Importmap, no Node build step |
| Front end | Hotwire (Turbo + Stimulus), Bootstrap 5.3.8 from CDN |
| Background jobs | Solid Queue |
| Cache / WebSockets | Solid Cache, Solid Cable |
| Tests | Minitest, Capybara, Selenium |
| Linting | RuboCop (rails-omakase) |
| Security scanning | Brakeman, bundler-audit |
| CI | GitHub Actions (`.github/workflows/ci.yml`) |
| Deployment | Kamal + Docker (configured, not deployed) |

Apart from Devise and Bootstrap, everything is a Rails 8 default. Nothing
exotic, on purpose.

## Requirements

Ruby 4.0.6, Bundler, and Git. No Node.js: importmaps serve JavaScript modules
straight to the browser, so there is no `package.json` and no `node_modules`.

## Getting started

```bash
git clone https://github.com/nataskasparaitis/friends-web.git
cd friends-web
bin/setup          # installs gems, prepares the database, clears old logs
bin/rails server
```

Open http://localhost:3000, click **Sign Up**, and add your first friend.

## Common commands

| Command | What it does |
|---|---|
| `bin/rails server` | Start the dev server on port 3000 |
| `bin/rails console` | Interactive console with the app loaded |
| `bin/rails db:prepare` | Create the database and run pending migrations |
| `bin/rails db:migrate` | Run pending migrations |
| `bin/rails routes` | List every route, including the ones Devise adds |
| `bin/rails test` | Run the test suite |
| `bin/rubocop` | Check code style |
| `bin/brakeman` | Scan for security issues |
| `bin/bundler-audit` | Check gems for known vulnerabilities |
| `bin/ci` | Run everything CI runs, locally |
| `bin/jobs` | Start the Solid Queue background worker |

Prefer `bin/rails` over bare `rails`. The binstub runs through Bundler with the
exact versions in `Gemfile.lock`, while bare `rails` uses whatever is newest on
the machine. That difference causes a lot of confusing errors.

## Data model

```
User                          Friend
  email                         first_name   required, max 50
  encrypted_password            last_name    required, max 50
  reset_password_token          email        required, must look like an email
  reset_password_sent_at        phone        optional, max 30
  remember_created_at           twitter      optional, max 50
  has_many :friends             user_id      indexed
                                belongs_to :user  (required)
```

Three migrations, in order: create friends, Devise users, then add `user_id` to
friends. That order is why `user_id` is a plain integer column with an index
rather than a foreign key reference.

`Friend#full_name` joins the two name fields, and `Friend.search` does a
case-insensitive partial match across all five text columns. `search` returns
the relation untouched when the query is blank, so it chains cleanly off
`current_user.friends` whether or not anything was typed into the navbar.

## How authentication and ownership work

Devise handles registration, sessions, password reset, and "remember me". The
enabled modules are `database_authenticatable`, `registerable`, `recoverable`,
`rememberable`, and `validatable`. Passwords are stored as bcrypt hashes in
`encrypted_password`, never in plain text.

`FriendsController` requires a signed-in user for every action via
`before_action :authenticate_user!`.

Ownership is enforced by the query rather than by a separate permission check.
`index` reads from `current_user.friends`, and `set_friend` looks records up
with `current_user.friends.find_by(id:)`, so `show`, `edit`, `update`, and
`destroy` are all covered by the same rule: another user's record is simply not
found, and the request is redirected back to the list with a message. New
records are built with `current_user.friends.build`, and `user_id` is not a
permitted parameter, so ownership cannot be set or changed through a form post.

The upshot is that there is one place to get this right instead of four, and
adding an action later does not mean remembering to add a permission check.

## Project structure

```
app/
  controllers/    friends (CRUD), home (static pages), application
  models/         Friend (validations, search), User (Devise)
  views/
    friends/      index, show, new, edit, _form, plus .json.jbuilder templates
    home/         index, about, _header (navbar and search form)
    devise/       generated auth views
    layouts/      application.html.erb, _alerts partial
  javascript/     Stimulus controllers and the importmap entrypoint
config/
  routes.rb       devise_for :users, resources :friends, root to friends#index
  initializers/devise.rb
db/
  migrate/        three migrations
  schema.rb       generated, never edit by hand
test/             Minitest, mirroring app/
```

## Testing

```bash
bin/rails test                                 # everything
bin/rails test test/models                     # one directory
bin/rails test test/models/friend_test.rb:12   # one test, by line
```

`test/test_helper.rb` mixes `Devise::Test::IntegrationHelpers` into every
integration test, so `sign_in users(:one)` is available anywhere.

Fixtures live in `test/fixtures`. There are two users, each owning one friend,
which is what makes the ownership tests possible. User passwords in the fixtures
are hashed with `Devise::Encryptor.digest`, the same way Devise hashes them at
sign-up, so fixture users can actually sign in.

Covered so far: model validations and search behaviour, redirect to sign-in when
signed out, that the list and the JSON payload contain only your own friends,
that search filters, that a submitted `user_id` is ignored, and that viewing,
editing, updating, or deleting another user's friend all fail.

## Deployment

Configured for Kamal, which builds the Docker image and runs it on a server over
SSH. Settings live in `config/deploy.yml`, secrets in `.kamal/secrets`. Nothing
is deployed yet; Kamal is present because it ships with Rails 8.

## Development notes

**Do not commit `config/master.key`.** It decrypts `config/credentials.yml.enc`
and is already in `.gitignore`. Keep it that way.

## Roadmap

- [x] Application scaffolding
- [x] `Friend` model, migration, and CRUD
- [x] User accounts and sessions with Devise
- [x] Ownership enforced through `current_user.friends` on every action
- [x] Validations on `Friend`
- [x] Working navbar search
- [x] Model and controller tests, including ownership isolation
- [x] Bootstrap styling and flash messages
- [ ] Pagination once a list outgrows one page
- [ ] Avatars via Active Storage
- [ ] System tests with Capybara
- [ ] Deploy

## License

Learning project. Not licensed for reuse.
