# Overview
A collection of microservices for interacting with [Reddit](https://reddit.com). Deployments are automated via Terraform into AWS cloud.

# Getting Started
See the sub-directory for each microservice for deployment and customization instructions.

* `sentiment` evaluates top comments, returning `positive`, `neutral`, `negative`, or `mixed` - using AWS Comprehend NLP.
* `removalwatch` periodically captures popular posts removed through moderator actions - similar to [FrontpageWatch](https://www.reddit.com/user/FrontpageWatch/).
