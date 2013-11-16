Trello-OmniFocus
================

Sends OmniFocus task status to Trello

Example: [http://conquerllc.com/trello-omnifocus/](http://conquerllc.com/trello-omnifocus/)

### Deployment Watcher ###

Start with ```./scripts/autodeployer.sh```

### Resources ###

- Trello
   - [Trello API Docs](https://trello.com/docs/api/index.html)
   - [Trello Client.js Docs](https://trello.com/docs/gettingstarted/clientjs.html)
   - [Trello Application Keys](https://trello.com/1/appKey/generate)
- OmniFocus
   - 
   

   
### Deployment Dependencies ###

- Linux
   - inotify-tools - ```apt-get install inotify-tools```
- OSX
   - [fswatch](https://github.com/alandipert/fswatch)
      git submodule init && git submodule update
      cd lib/fswatch/
      make
      cd ../../
      
      
    - If you want notifications:
       1. ```sudo gem install terminal-notifier```, OR
       2. Install Growl Notify:
          1. [Growl](https://itunes.apple.com/us/app/growl/id467939042?mt=12&ign-mpt=uo%3D4)
          1. [Growl Notify](http://growl.cachefly.net/GrowlNotify-2.1.zip)