# inetkami.rb - infobot for twitter...in Ruby
---

## Introduction
---
Infobots have a long history and tradition on IRC.  This is a sort of equivalent for twitter -- optimized for information one might like to get while travelling in a form that's usable via an SMS-enabled non-smartphone.


## History & Rationale
---
Inetkami was originally written in Perl, back in the days when mobile data in Canada was even more obscenely expensive than it is now.  Using Twitter as a bridge, Inetkami let you use SMS to retrieve information you find useful when you're out and about -- information that you might otherwise have to use mobile data for.

Nowadays data is somewhat less spendy, but retrieving things like weather and road conditions via a terse Twitter message can still be more convenient than wrestling with apps and mobile webpages.  Besides, it's a fun side-project as well.


## Setup & Config
---
This is still very much alpha-quality software -- written to scratch a personal itch, and still under active development.  That said, you are more than welcome to have a go if you like:

* Create a Twitter account for your bot.
* Generate a set of Twitter API keys:  https://apps.twitter.com/
* Copy the example config file `inetkami.cfg.example` to `inetkami.cfg`.
* Edit `inetkami.cfg`.  Replace the placeholder values of `consumer_key`, `consumer_secret`, `access_token`, and `access_token_secret` with your own.
* Start the program with `ruby inetkami.rb`.


## Example instance
---
There is an example instance running on Twitter as [@inetkami](https://twitter.com/inetkami/with_replies), assuming it hasn't crashed or had its server go down.  Please be gentle. 😊
