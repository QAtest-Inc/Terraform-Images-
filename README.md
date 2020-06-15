# Terraform Images

This repository provides a docker image which contains the `gitlab-terraform` shell script. This script is a thin wrapper around the `terraform` binary. It's main purpose is to serve the [Infrastructure as code with Terraform and GitLab
](https://docs.gitlab.com/ee/user/infrastructure/), by extracting some of the standard configuration a user would need to set up to use the Terraform backend on GitLab as well as the Terraform merge request widget.

# How to use it

The wrapper expects three environment variables to be set:

### `TF_ADDRESS`

Should be the backend url. For the GitLab backend it will be something like,

`"{GITLAB_API_URL}/projects/{PROJECT_ID}/terraform/state/{STATE_NAME}"`

- `{GITLAB_API_URL}` is the URL of your GitLab API.
- `{PROJECT_ID}` is the id of the project you're using as your infrastructure as code.
- `{STATE_NAME}` can be arbitrarily defined to the Terraform state name one wants to create.

### `GITLAB_USER_LOGIN`

Is your user login name, which must have maintainer access.

### `GITLAB_TF_PASSWORD`

An access token created for the above maintainer with the api scope.

# How to contribute?

Contributions are always welcome. Don't be shy!

If there's no other issue already discussing what you want, simply open a new issue and the maintainers will gladly review it and come back to you as soon as possible. If there's an open issue with the "Accepting merge requests" label, simply open up a merge request proposal linking to that issue and we'll also review it as soon as possible.

# Release

Currently we release two versions of this image. One with support for terraform 0.12 and the other for 0.13 (beta). We're still deciding on how many and which versions versions of terraform we want to support. For now, we're testing and building for these two. Our main idea was to guarantee support for the last two stables, but using 0.11 was requiring some smelly workaround setup to make it working, we decided to not guarantee support for it for now.

Each released image will be updated whenever a new change is pushed to master. We plan to introduce [Semantic Versioning with Conventional Commits](https://gitlab.com/gitlab-org/terraform-images/-/issues/1) soon.