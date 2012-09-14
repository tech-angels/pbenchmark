# Slanger-benchmark

  A simple tool to benchmark Pusher.com compatible servers.
  
  [![Dependency Status][2]][1]
  
  [1]: https://gemnasium.com/tech-angels/pb
  [2]: https://gemnasium.com/tech-angels/pb.png

## Getting started

Install required gems with bundler:

    bundle install

Run it against your server, for example a slanger daemon:

    ruby slanger-benchmark.rb -c 10 -n 5 -i 43 -k bcff8137f9c04db491199d4578a37286 -s 68f5400d1aaa4d1bbaaf70bb0b866cb7 -a 127.0.0.1:80 -w 127.0.0.1:8080

Messages are sent via the API, and the time it took them to reach the websocket clients is printed.

## Commmand line parameters

<pre>
-c Number of websocket clients.

-n Number of messages to send via the API.

-i Application ID.

-k Application key.

-s Application secret.

-a API host and port. Example: 127.0.0.1:80.

-w Websocket server host and port. Example: 127.0.0.1:8080

--size Payload size in bytes.
</pre>

## Credits

  Gilbert Roulot @ Tech-angels - http://www.tech-angels.com/
  
  [![Tech-Angels](http://media.tumblr.com/tumblr_m5ay3bQiER1qa44ov.png)](http://www.tech-angels.com)


