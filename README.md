# Terraform Images

This repository provides a docker image which contains the `gitlab-terraform` shell script. This script is a thin wrapper around the `terraform` binary. Its main purpose is to serve the [Infrastructure as code with Terraform and GitLab
](https://docs.gitlab.com/ee/user/infrastructure/), by extracting some of the standard configuration a user would need to set up to use the Terraform backend on GitLab as well as the Terraform merge request widget.

# How to use it

The wrapper expects three environment variables to be set:

### `TF_ADDRESS`

Should be the backend url. For the GitLab backend it will be something like,

`"{GITLAB_API_URL}/projects/{PROJECT_ID}/terraform/state/{STATE_NAME}"`

- `{GITLAB_API_URL}` is the URL of your GitLab API.
- `{PROJECT_ID}` is the id of the project you're using as your infrastructure as code.
- `{STATE_NAME}` can be arbitrarily defined to the Terraform state name one wants to create.

### `TF_USERNAME`

Is your user login name, which must have maintainer access. If this is unset, it will default to the value of GITLAB_USER_LOGIN which is the username that triggered the build.

### `TF_PASSWORD`

An access token created for the above maintainer with the api scope. If this is unset, it will default to the value of CI_JOB_TOKEN and override the TF_USERNAME to match.

# How to contribute?

Contributions are always welcome. Don't be shy!

If there's no other issue already discussing what you want, simply open a new issue and the maintainers will gladly review it and respond as soon as possible. If there's an open issue with the "Accepting merge requests" label, simply open up a merge request proposal linking to that issue and we'll also review it as soon as possible.

## Git Commit Guidelines

This project uses [Semantic Versioning](https://semver.org). We use commit
messages to automatically determine the version bumps, so they should adhere to
the conventions of [Conventional Commits (v1.0.0)](https://www.conventionalcommits.org/en/v1.0.0/).

# Release

Currently we release two versions of this image. One with support for terraform 0.12 and the other for 0.13. We're still deciding on how many and which versions of terraform we want to support. For now, we're testing and building for these two. Our main idea was to guarantee support for the last two stables.
