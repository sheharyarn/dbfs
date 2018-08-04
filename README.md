DBFS
====

> Distributed Blockchain-based File Storage in Elixir 📡

`DBFS` is an experiment to implement a (very naïve) distributed file storage service using a blockchain
in Elixir. With growing interest in Blockchains and Cryptocurrencies, I wanted to understand the complex
inner workings of Blockchains and their feasibility in the context of business applications. I started
by writing a [very simple Blockchain][blog-blockchain] to get started, and then wrote `DBFS` as a
slightly more complex version that actually did something.




## Screenshots, Talk and Paper

I gave a lightning talk about the project at the [ElixirConf 2018 in Europe][elixirconf-eu], which you
can check out [here][talk-2018].

[<img src="./media/elixirconf-talk.png" height="300px" />][talk-2018]

I also wrote a [basic whitepaper][whitepaper] detailing the project as part of my semester project, and
you can also see some screenshots of the application here:

<table>
<tr>
  <td><img src="./media/screenshot-1.png" height="150px" /></td>
  <td><img src="./media/screenshot-2.png" height="150px" /></td>
  <td><img src="./media/screenshot-3.png" height="150px" /></td>
</tr>
</table>




## Architecture

The application is divided into two parts:

 - [Elixir Backend][dbfs]: The core application, responsible for storing the data, performing consensus
   among nodes and exposing an API for clients
 - [React Frontend][dbfs-web]: A Javascript based web-client that connects to the backend, provides a UI
   to perform operations and displays statistics about all the connected nodes.

The application is designed as a "Private Blockchain" after weighing the pros and cons of different
approaches, and even though it should _absolutely not be used in production_, it is meant to be run on
private infrastructure instead of being made publicly available so any node can connect.

The `sys.config` file defines 3 nodes. You can change this to add or remove nodes, but you'll have to
perform the setup on each node (if you're running it on different machines). You'll also have to make
sure that your `hosts` file points these domains to their correct IPs.

 - `node_1@dbfs.newyork`
 - `node_2@dbfs.london`
 - `node_3@dbfs.singapore`




## Setup

You need to have these dependencies installed at minimum:

 - **Erlang/OTP 20.1**
 - **Elixir 1.5.2**
 - **Postgres 9.4**
 - **Node.js 9.6.1** for Yarn
 - **Ruby 2.3.3** for Sass

Set up the Backend:

```bash
$ git clone to.shyr.io/dbfs ~/dbfs
$ cd ~/dbfs
$ mix deps.get
$ mix compile
```

Set up the Frontend:

```bash
$ git clone to.shyr.io/dbfs-web ~/dbfs-web
$ cd ~/dbfs-web
$ yarn install
```

For the first node of the backend, we need to create its instance and initialize the blockchain database.
For other nodes, we can simply create their instances without creating the blockchain (They will
automatically be synchronized when we start them). Assuming, you're starting all nodes on the same machine:

```bash
$ cd ~/dbfs
$ NODE=newyork   PRIMARY=1 mix do ecto.create, ecto.migrate, ecto.seed
$ NODE=london    PRIMARY=0 mix do ecto.create, ecto.migrate, ecto.seed
$ NODE=singapore PRIMARY=0 mix do ecto.create, ecto.migrate, ecto.seed
```




## Get it Running

To finally start the backend nodes, you need to pass them a port, node name and boot-up config. You can
start one node or multiple, depending on the requirements.

```bash
$ NODE=newyork PORT=3000 elixir --name node_1@dbfs.newyork --erl "-config sys.config" –S mix phoenix.server
```

If you decide to run multiple nodes together, you also need to initialize the distributed Mnesia tables
which are responsible for performing consensus across the network. First enter the REPL command-line of one
of the running nodes, and enter the following:

```elixir
iex> DBFS.Consensus.Global.setup
```

Finally, to start the Web-Client:

```bash
$ cd ~/dbfs-web
$ PORT=4000 yarn start
```




[dbfs]:             https://github.com/sheharyarn/dbfs
[dbfs-web]:         https://github.com/sheharyarn/dbfs-web
[blog-blockchain]:  https://sheharyar.me/blog/writing-blockchain-elixir/
[talk-2018]:        https://speakerdeck.com/sheharyar/dbfs-elixirconf-eu-2018-lightning-talk
[whitepaper]:       https://jmp.sh/83yHQva
[elixirconf-eu]:    http://elixirconf.eu/

[img-talk]:         ./media/elixirconf-talk.png
[img-shot-1]:       ./media/screenshot-1.png
[img-shot-2]:       ./media/screenshot-2.png
[img-shot-3]:       ./media/screenshot-3.png
