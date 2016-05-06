# Ports
This document acts as a register of port reservations for our various services.

|          Service           |  Port | Public | Notes |
|----------------------------|-------|--------|-------|
| SSH                        | 22    | x      |       |
| HTTP                       | 80    | x      |       |
| HTTPS                      | 443   | x      |       |
| app PostgreSQL             | 5500  |        |       |
| Reserved for PostgreSQL    | 55XX  |        |       |
| app Redis                  | 6400  |        |       |
| Reserved for Redis         | 64XX  |        |       |
| app                        | 9000  |        |       |
| app test server            | 9001  |        |       |
| Reserved for applications  | 90XX  |        |       |
| Load balanced PostgreSQL   | 155XX |        |       |
| Load balanced Redis        | 164XX |        |       |
| Load balanced applications | 190XX |        |       |
