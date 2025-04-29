---
date: 2024-05-07 09:00
description: Homebrew bottles offer great potential for improving formulae install times, but have some idiosyncracies that I discovered while setting up my own. I'm sharing that knowledge here for community benefit.
tags: engineering, homebrew, ci-cd
author: Annalise Mariottini
title: The Missing Guide to Homebrew Bottles
---

## Motivation

I recently had the opportunity to set up Homebrew bottles for my team's Homebrew tap. While documentation for bottling is not [totally absent from Homebrew's site](https://docs.brew.sh/Bottles), it does leave out some key points about the bottling process, especially for those who wish to bottle in a CI/CD context.

In this article, I'll share what I learned about bottling to benefit those who wish to do the same for their own custom taps. For demonstrative purposes, I'm going to refer to a custom tap `custom-tap` owned by `my-team`, with an example formula `awesome-cli`. These can stand in for your own team, custom tap, and formula.

### What I'm Not Going To Talk About

I'm _not_ going to cover how to setup your own Homebrew tap here ([Homebrew's documentation is pretty good on this topic](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)). While I will offer some suggestions on getting bottling automated with CI/CD, I will not offer details specific to any particular platform (e.g. GitHub, GitLab).

## Why Bottle?

The platform team I'm currently on maintains a custom homebrew tap where we vend multiple CLIs. Our heaviest used CLI is also our mostly frequently updated --- often multiple times per week. Since `brew install` builds binaries from source by default, install times were abysmal, clocking in somewhere around 5 minutes. On one hand, we want to ship our CLI additions and improvements to all its users as soon as their available; on the other hand, users were often deterred from installing due to the disruption an install forces upon their workflow.

It was at this point I decided to look into bottles with Homebrew. For context, bottles are simply Homebrew's terminology for binary packages. Especially since most of our users are on similar platforms, distributing via binaries would be a straightforward way to speed up install times drastically.

## Building the Bottles

I started at the most obvious place: [Homebrew's own bottle documentation](https://docs.brew.sh/Bottles). I was happy to find this dedicated page on their site, as it gave me a good place to start. I'd recommend you taking a quick pass over it yourself, if you haven't already. If I were happy with manually bottling my formulae, this probably would have been good enough; however, my goal was to automate CI/CD for formula publishing, which would require automating the bottling process. This is where things started getting tricky.

### How is a Bottle Made?

A bottle is made when you pass the `--build-bottle` flag to `brew install`. This is already where we hit our first "gotcha" for automating: to build bottles, you must **not** have your formula installed locally already. Use `brew uninstall --force awesome-cli` to ensure that uninstalling should always succeed.

After installing with the special flag, we need `brew bottle`. This creates a tarball and also outputs some special code for our formula.

Let's try it out!

```sh
$ brew install awesome-cli --build-bottle
==> Fetching my-team/custom-tap/awesome-cli
==> Downloading https://www.github.com/my-team/homebrew-custom-tap
==> Installing awesome-cli from my-team/custom-tap
==> make install
==> Not running 'post_install' as we're building a bottle
You can run it manually using:
  brew postinstall my-team/custom-tap/awesome-cli
🍺  /opt/homebrew/Cellar/awesome-cli/0.0.0: 3 files, 26.3MB, built in 5 minutes 21 seconds
==> Running `brew cleanup awesome-cli`...
$ brew bottle awesome-cli
==> Determining my-team/custom-tap/awesome-cli bottle rebuild...
==> Bottling awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz...
==> Detecting if awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz is relocatable...
./awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz
  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "bbe8426ddfc49fec1af20a486e28e44bab79efca38818ad6c5841cc7a7c86b12"
  end
$ ls | grep awesome-cli
awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz
```

As you can see in the above output, `--build-bottle` does... something? I'm still not sure exactly what. However, what matters is that with `brew bottle` we have our tarball ready for distribution, along with some helpful ruby lines of code to add to our formula.

Now I just needed to figure out how to bottle in a way that faciliated automated formulae updating, since printing to stdout isn't good enough.

### Digging Into the `bottle` Command

We can actually find some help in a pretty obvious place:

```sh
$ brew bottle --help
Usage: brew bottle [options] installed_formula|file [...]

Generate a bottle (binary package) from a formula that was installed with
--build-bottle. If the formula specifies a rebuild version, it will be
incremented in the generated DSL. Passing --keep-old will attempt to keep it
at its original value, while --no-rebuild will remove it.

      --skip-relocation            Do not check if the bottle can be marked as
                                   relocatable.
      --force-core-tap             Build a bottle even if formula is not in
                                   homebrew/core or any installed taps.
      --no-rebuild                 If the formula specifies a rebuild version,
                                   remove it from the generated DSL.
      --keep-old                   If the formula specifies a rebuild version,
                                   attempt to preserve its value in the
                                   generated DSL.
      --json                       Write bottle information to a JSON file,
                                   which can be used as the value for --merge.
      --merge                      Generate an updated bottle block for a
                                   formula and optionally merge it into the
                                   formula file. Instead of a formula name,
                                   requires the path to a JSON file generated
                                   with brew bottle --json formula.
      --write                      Write changes to the formula file. A new
                                   commit will be generated unless --no-commit
                                   is passed.
      --no-commit                  When passed with --write, a new commit will
                                   not generated after writing changes to the
                                   formula file.
      --only-json-tab              When passed with --json, the tab will be
                                   written to the JSON file but not the bottle.
      --no-all-checks              Don't try to create an all bottle or stop a
                                   no-change upload.
      --committer                  Specify a committer name and email in git's
                                   standard author format.
      --root-url                   Use the specified URL as the root of the
                                   bottle's URL instead of Homebrew's default.
      --root-url-using             Use the specified download strategy class for
                                   downloading the bottle's URL instead of
                                   Homebrew's default.
  -d, --debug                      Display any debugging information.
  -q, --quiet                      Make some output more quiet.
  -v, --verbose                    Make some output more verbose.
  -h, --help                       Show this message.
```

The options `--json`, `--merge`, and `--write` look the most intriguing. It appears that if I use some combination of these flags, I'll be able to automatically write bottle changes to my formula file. Awesome!

Take note:
* The `--write` flag implicitly creates a new git commit when used. Luckily, the `--no-commit` flag can be used to skip this.
* The `--root-url` option is going to come in handy a bit later. Keep it in the back of your mind for now.

Using those flags and options, let's see what we get.

```sh
$ cd ~/my-team/homebrew-custom-tap/
$ brew uninstall --force awesome-cli
$ brew install awesome-cli --build-bottle
$ brew bottle awesome-cli --json
==> Determining my-team/custom-tap/awesome-cli bottle rebuild...
==> Bottling awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz...
==> Detecting if awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz is relocatable...
./awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz
  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "bbe8426ddfc49fec1af20a486e28e44bab79efca38818ad6c5841cc7a7c86b12"
  end
$ ls | grep awesome-cli
awesome-cli--0.0.0.arm64_sonoma.bottle.1.tar.gz
awesome-cli--0.0.0.arm64_sonoma.bottle.json
$ brew bottle awesome-cli--0.0.0.arm64_sonoma.bottle.json --write --merge --no-commit
==> my-team/custom-tap/awesome-cli
  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "30eca9404fb2965fe0cc0605c902e54dcd8461a7063a824d71b5536ad6993b14"
  end
```

Now, let's see our change:

```sh
$ git diff HEAD
```

...aaaaand, nothing. This one had me scratching my head for a while, but to save you time, let me give you a hint:

```sh
cd $(brew --repo my-team/custom-tap)
```

It turns out, when using `--write`, the fomula file that's changed isn't in the repository in which the command is excuted. Instead, `brew` goes to its own clone to make the file change, which is in the directory returned by `brew --repo my-team/custom-tap`.

```sh
$ cd $(brew --repo my-team/custom-tap) && git diff HEAD
diff --git a/Formula/awesome-cli.rb b/Formula/awesome-cli.rb
index e823733..ea0a492 100644
--- a/Formula/awesome-cli.rb
+++ b/Formula/awesome-cli.rb
@@ -7,8 +7,8 @@ class AwesomeCli < Formula
   license ""
 
+  bottle do
+    rebuild 1
+    sha256 cellar: :any_skip_relocation, arm64_sonoma: "30eca9404fb2965fe0cc0605c902e54dcd8461a7063a824d71b5536ad6993b14"
+  end
```

Now that looks more like it.

In the automation script I eventually finalized, I decided to let `brew` do the committing and left off `--no-commit`. It's up to you whether you'd this route, or whether you'd like to commit the formula changes in a different manner.

Ok, so I have my formula edited, but how does `brew` know where to find my tarball on install?

## Distributing Bottles

In order to distribute bottles, we need to put the bottle tarball in some place that `brew` can find it. My team uses [Artifactory](https://jfrog.com/artifactory/) for such purposes (the successor of the now defunct Bintray). Homebrew uses [GitHub Packages](https://github.com/features/packages). I'll leave it up to you to decide where you want to put your bits.

But before you do, here's another lesson I learned, to save you some time: even though the generated tarball file has 2 dashes ("--") after the formula name, the file name that `brew` _expects_ to find should only have 1 dash ("-"). It turns out, we can check the generated JSON file for the fields `local_filename` and `filename` to know the filename brew generates upon bottling and the filename it expects to find when installing from bottles, respectively ([according to the maintainers, this is required for backward-compatibility](https://github.com/orgs/Homebrew/discussions/4541#discussioncomment-6033307e)).

```
{
  "my-team/custom-tap/awesome-cli": {
    "formula": {
      "name": "awesome-cli",
      "pkg_version": "0.0.0",
      "path": "Library/Taps/my-team/homebrew-custom-tap/Formula/awesome-cli.rb",
      "tap_git_path": "Formula/awesome-cli.rb",
      ...
    },
    "bottle": {
      "root_url": "<some root URL>",
      "cellar": "any_skip_relocation",
      "rebuild": 1,
      "date": "2024-05-06",
      "tags": {
        "arm64_sonoma": {
          "filename": "awesome-cli-0.0.400.arm64_sonoma.bottle.1.tar.gz",
          "local_filename": "awesome-cli--0.0.400.arm64_sonoma.bottle.1.tar.gz",
          ...
        }
      }
    }
  }
}
```

At this point, I'll also mention how to use the `--root-url` option with `brew bottle` to get the correct bottle lines added to your formula. The root URL should be the hosted directory that will contain your tarball. So, if your binary is hosted at `my-team.some-site.com/path/to/binaries/`, then you should pass in that value for `--root-url` during the _first_ `brew bottle` step (along with `--json`). This means our brew bottle steps now look something like:

```sh
$ brew uninstall --force awesome-cli
$ brew install awesome-cli --build-bottle
$ brew bottle awesome-cli --json --root-url https://my-team.some-site.com/path/to/binaries/
$ cp awesome-cli--0.0.0.arm64_sonoma.bottle.tar.gz awesome-cli-0.0.0.arm64_sonoma.bottle.tar.gz
$ curl https://my-team.some-site.com/path/to/binaries/ --upload-file awesome-cli-0.0.0.arm64_sonoma.bottle.tar.gz
$ brew bottle awesome-cli--0.0.0.arm64_sonoma.bottle.json --write --merge --no-commit
```

I'm being a bit naive in the above script for clarity. At minimum, you should parse the JSON file to get the values for `local_filename` and `filename`, as I mentioned before. How much flexibility you need for other variables, like versioning, the formula name, the deploy location, authorization, etc., will depend on your own individual or team requirements. I'd also highly recommend using `--verbose` wherever possible, in the case something goes wrong.

The last thing to do is to push the changes in the homebrew repo to the remote, and your formula bottle should be available for consumption. 🍾🍺

## Some Notes on CI/CD

I don't want to prescribe to you a specific way to automate your formulae publishing, as every setup will have slight nuances that warrant different solutions. However, I wanted to describe in short steps what my team found to be a successful automated formulae publishing setup:

1. In the repository that contains the source code for formulae (I'll call it `my-team-tools`), create a new git tag whenever its time to publish a new formula, with the tag name format `<formula>@<version>` (we use this format to support multiple formulae being published from the same repo).
2. In `my-team-tools`, setup a CI job that runs only on new git tags, parsing the formula and version from the tag name and setting them as environment variables.
3. In this job, checkout a new branch from `homebrew-custom-tap` and write new values (e.g. installation url, version, sha256) to the ruby formula file, not including the bottle lines. We use a template file to do this.
4. Commit these changes with a predefined format, like `Updating <formula> to <version>`. Push this branch to the remote.
5. In `homebrew-custom-tap`, setup a CI job that runs when the commit message is `Updating <formula> to <version>`, parsing out those values as environment variables in the job.
6. Run formula bottling in this job on `homebrew-custom-tap`. If bottling succeeds, then merge the branch to the default branch. You can then delete the branch from the remote.

We found the above steps work well for our team. We have a reasonably high value of changes being made both to formulae source code, along with non-formulae source code in the same repository.

### Targeting Different Architectures

My team is fortunate enough that the vast majority of our user base is on the same version of macOS and stay very up-to-date with their updates. However, if you need to provide bottles for different architectures, you'll need to build each bottle on the architecture you're targeting. This can be achieved by setting your VM images accordingly during bottling, and breaking up bottling into multiple steps, one for each architecture.

## Using BrewTestBot

Observant readers might have noticed that Homebrew mentions a [BrewTestBot](https://docs.brew.sh/BrewTestBot) in their [Bottles documentation](https://docs.brew.sh/Bottles#creation). This is what Homebrew itself uses to validate formulae changes and publish bottles for formulae updates. While this was promising, and the route suggested by [another article on bottle publishing](https://jonathanchang.org/blog/maintain-your-own-homebrew-repository-with-binary-bottles/), my team found greater value in a more "slimmed down" publishing script. By using the `bottle` command directly, we also ensure maximum control over the nuances of code flow and graceful failure.

## Closing

I hope you found the information contained in this article useful! Throughout the article, I've explicitly linked and called out any resources I found notably useful in compiling together the information I needed to achieve Homebrew formulae bottling. Cheers!