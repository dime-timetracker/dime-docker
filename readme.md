DIME Timetracking Server
========================

Installation
------------

0. Make sure, you have [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/) in an up-to-date version.
1. Clone this repository recursively: ``git clone --recursive git://github.com/dime-timetracker/dime-docker.git dime``.
2. Optionally, customize the port, you want Dime to be running on. Therefore, replace
   ``8100`` in ``docker-compose.yml`` by your preferred port. As an example, if
   you want to run Dime on port 80, you should end up with a line
   ``      - "8100:80"``. Please take care of the indentation.
3. Create frontend config file: ``cd dime; cp frontend/src/parameters.js.template frontend/src/parameters.js`` and edit your base url in there.
4. Build the frontend: ``cd frontend; npm install; npm build`` and the backend: ``cd server; composer install``.
5. Run ``docker-compose up`` to start the servers (Varnish, API server, database
   and frontend).

After that, you should be able to call your Dime instance in the browser.
