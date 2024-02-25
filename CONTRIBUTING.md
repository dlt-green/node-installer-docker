![GitHub latest release](https://img.shields.io/github/v/release/dlt-green/Node-Installer-docker)
![GitHub release date](https://img.shields.io/github/release-date/dlt-green/Node-Installer-docker)
![GitHub contributors](https://img.shields.io/github/contributors/dlt-green/Node-Installer-docker)
![GitHub license](https://img.shields.io/github/license/dlt-green/Node-Installer-docker)

# DLT.GREEN Decentralized collaboration

Decentralized collaboration in particular requires rules that are followed by everyone but also monitored by everyone. These rules must be adhered to by every collabrator, changes to these rules require a minimum number of reviews and there must be no objection (changes requested)

## DLT.GREEN Automatic Node-Installer for Docker - Branches

We have different branches in our repo, it is important to understand which branch is used for what, and which branch can be merged into which one until the release is finally published.

### Branch: main

This branch reflects the currently published release. By default it is not possible for a single person to merge into this branch. It is subsequently also forbidden. Merges into this branch are exclusively done by a Github bot via a pull request, which must be reviewed through the collaborators before. A minimum number of reviews from the collaborators are necessary for a successful merge into the main branch.

This branch reflects the "dlt.green" installer

```console
https://github.com/dlt-green/node-installer-docker/releases/latest
```

### Branch: dev

This branch is intended as an intermediate step for testing further developments before it is released. Major changes may not be made directly in this branch. This is more intended to test the release beforehand. It must be possible at any time to release the dev branch promptly or immediately (e.g. for node updates or hotfixes).  Small changes without objection from the collaborators can be pushed directly, which have no impact on functionality. If it is uncertain whether the necessary number of reviews will be achieved, or if there are changes to the functionality, open a feature branch for that.

This branch can be tested with the "dlt.green-dev" installer

```console
https://github.com/dlt-green/node-installer-docker/releases/tag/dev-latest
```

### Branch: feature/xyz

Feature branches are used for further development of the installer and should always be copied from the dev branch. Such a branch may only be opened with the consent of the collaborators or no objection from a collaborator. If you create a branch for a feature "xyz", then name it "feature/xyz" without exception. This branch will also be built immediately for testing, and the installer can also be started from this branch. You see the files under ”xyz-latest” as pre-release. If the feature is to be released soon, a pull request can be made into the dev branch. A pull request in the main branch will be deleted immediately without prior notice.

This branch can be tested with direct access to the pre-release

```console
https://github.com/dlt-green/node-installer-docker/releases/tag/xyz-latest
```

## DLT.GREEN Automatic Node-Installer for Docker - Automated Actions/Workflows

A pre-release for testing is automatically built for each branch. Since the installer and the files are monitored with hashes, these are automatically set by Github in the installer, no manual adjustment is necessary.

### Prepare release:

It is used for generating a pull request from dev branch into the main branch, after running the workflow a pull request is automatically generated to review from the collaborators, before it can be merged into the main branch. At the same time, a pre-release with the specified version was published, which becomes a release after review. In every pre-release version, the update flags are commented out in the installer

### Build wasp-cli docker image:

Since the image for the wasp cli on dockerhub is provided by dlt.green, this must be built and published for a new version. Here you just have to specify the corresponding wasp cli version for building.

## DLT.GREEN Automatic Node-Installer for Docker - Contributing through External Contributors

1.	Fork the repository
2.	Make a squashed pull request into our dev-branch
3.	Give it a meaningful title and add a description
4.	If the collaborators agree (3 reviews/no changes requested),
	it will be merged or, if rejected, it will not be merged.

## DLT.GREEN Automatic Node-Installer for Docker - Contributing through Collaborators

1.	Abide by the rules listed above
2.	Merging and preparing release may only be done through the dlt.green core team (dlt.green | 2g4y1 | Tito Bogenlos | Pascal Jeiziner)
3.	Titles of your commits must have the following structure:
	"part of the installer": "what is done" (e.g: "iota-wasp: update …", "wasp: fix …", "docker: …", "installer: add/rem/fix/update/upgrade/…"
4.	Titles of pull requests must be meaningful, and a description would be good to get faster reviews
5.	You need the approval (review) of at least 3 contributors and there must be no objection from any contributor (changes requested)
6.	It is advisable to find a consensus in our dlt.green x-team with the collabrators before acting in the repo, in order to subsequently receive the necessary reviews
7.	A new collabrator can be added with 75% approval via a vote with no objection from an active collabrator
8.	A collabrator can be deleted with 75% approval via a vote
9.	This rules must be reviewed from every collabrator
10.	Failure to comply with the rules will result in immediate exclusion without prior notice