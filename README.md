DBFS
====

> Distributed Blockchain-based File Storage in Elixir 📡

`DBFS` is an experiment to implement a (very naïve) distributed file storage service using a blockchain
in Elixir. With growing interest in Blockchains and Cryptocurrencies, I wanted to understand the complex
inner workings of Blockchains and their feasibility in the context of business applications. I started
by writing a [very simple Blockchain][blog-blockchain] to get started, and then wrote `DBFS` as a
slightly more complex version that actually did something.



## Architecture

The application is divided into two parts:

 - [Elixir Backend][dbfs]: The core application, responsible for storing the data, performing consensus
   among nodes and exposing an API for clients
 - [React Frontend][dbfs-web]: A Javascript based web-client that connects to the backend, provides a UI
   to perform operations and displays statistics about all the connected nodes.

The application is designed as a "Private Blockchain" after weighing the pros and cons of different
approaches, and even though it should _absolutely not be used in production_, it is meant to be run on
private infrastructure instead of being available publicly.



[dbfs]:             https://github.com/sheharyarn/dbfs
[dbfs-web]:         https://github.com/sheharyarn/dbfs-web
[blog-blockchain]:  https://sheharyar.me/blog/writing-blockchain-elixir/
[talk-2018]:        https://speakerdeck.com/sheharyar/dbfs-elixirconf-eu-2018-lightning-talk
