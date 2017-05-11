# Outline

## Goals
### To understand in what areas Elixir shines
### To understand how this influences how you architect your apps 

## Ruby is still good

## What is Elixir?
### Elixir / Erlang / OTP

## What kind of problems does it solve?
### Scale (vertical and horizontal scale — use all machine resources and distributed)
### Large amounts of background processing
#### Not just an afterthought
#### Not just sidekiq or cron jobs
#### Machine learning or real-time streaming of data
#### Communication between parts of the system

## How does it solve these problems?
### Incredible performance
### Fault tolerance
### App architecture

## How does it do this technically? -> Processes
### What is an Elixir process?
#### Lightweight
#### Isolated (memory management - no immutable state)
#### Concurrent

### How do processes work?
#### Spawning
#### Messages and mailboxes
#### send/receive/loop
#### Client/Server functions 
#### OTP abstractions
##### Agent
##### GenServer
##### Task
##### ETS

#### GenServer example

## How does it do it?

### Performance

> "Today we have tuned some knobs, shifted some traffic around and achieved 1 million established tcp sessions on a single machine (and with memory and cpu to spare!)"
> 
> - WhatsApp Blog - https://blog.whatsapp.com/170/ONE-MILLION%21?p=170

```
[info] GET /
[info] Sent 200 in 389µs
```

I was listening to a recent [Elixir Fountain episode](Episode 061: Elixir ABCs & 123s with Jesse J. Anderson) where the interviewee mentioned that his product hit the front page of Hacker News and it never went down on his Heroku hobby dyno.

#### microsecond response times
#### 1 million connections on a single server
#### Uses all available cores
#### -> Compiled and concurrent

### Fault tolerance
#### Crash/restart (exceptional circumstances should be exceptional - does not protect you from yourself)
#### Supervisor strategy 

### App architecture
#### Typical Rails app diagram (mostly Rails, some small things like db, redis, worker, etc.)
#### "Microservices" - everything is an app
#### Separation of concerns
#### "OOP"

## Demo

## Conclusion

### Elixir is made from very good parts
#### Developer happiness / productivity inspired by things like Ruby
#### It's got the power from the underlying Erlang

### Even if you don't use elixir the ideas behind how processes communicate can help you write better software 
### This is exciting technology and cool things (like Nerves and Phoenix) will pop up around it

## Resources

### Elixir docs - http://elixir-lang.org/
### Hex docs - Show pic - https://hexdocs.pm/elixir/GenServer.html
### Elixir school - https://elixirschool.com/
### Elixir In Action (book) - https://www.manning.com/books/elixir-in-action

## Questions?