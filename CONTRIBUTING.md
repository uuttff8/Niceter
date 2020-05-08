## Contribution Guidelines

Niceter is the actively developed open source project by uuttff8. This document is setup to ensure contributing to the project is easy and transparent.


Contributing to Niceter
=====================

#### Fork the Project

Fork the [project on Github](https://github.com/uuttff8/Niceter) and check out your copy.

```
git clone https://github.com/uuttff8/Niceter.git
cd Niceter
git remote add upstream https://github.com/uuttff8/Niceter.git
```

#### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

#### Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build.

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

#### Write Code

Implement your feature or bug fix.

Make sure that build completes without errors.

#### Write Documentation

Document any external behavior in the [README](README.md).

#### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/uuttff8/Niceter and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```


#### Thank You

Please do know that we really appreciate and value your time and work. We love you, really.