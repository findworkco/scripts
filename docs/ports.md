# Ports
This document acts as a register of port reservations for our various services.

|           Service           |  Port | Public |      Notes       |
|-----------------------------|-------|--------|------------------|
| SSH                         | 22    | x      |                  |
| HTTP                        | 80    | x      |                  |
| HTTPS                       | 443   | x      |                  |
| Supervisor                  | 2000  |        |                  |
| PostgreSQL 9.3              | 5500  |        |                  |
| Reserved for PostgreSQL     | 55XX  |        |                  |
| app Redis                   | 6400  |        |                  |
| app test Redis              | 6401  |        |                  |
| Reserved for Redis          | 64XX  |        |                  |
| app test fake Google server | 7000  |        |                  |
| Reserved for fake servers   | 70XX  |        |                  |
| app                         | 9000  |        |                  |
| app test server             | 9001  |        |                  |
| Reserved for applications   | 90XX  |        |                  |
| Load balanced PostgreSQL    | 155XX |        |                  |
| Load balanced Redis         | 164XX |        |                  |
| Load balanced applications  | 190XX |        |                  |
| LiveReload                  | 35729 |        | Development only |
