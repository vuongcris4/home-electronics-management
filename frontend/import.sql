CREATE TABLE "CUSTOM_USER" (
  "id" INT PRIMARY KEY,
  "email" VARCHAR(255) UNIQUE,
  "name" VARCHAR(255),
  "phone_number" VARCHAR(20),
  "password" VARCHAR(255)
);

CREATE TABLE "ROOM" (
  "id" INT PRIMARY KEY,
  "name" VARCHAR(255),
  "user_id" INT
);

CREATE TABLE "DEVICE" (
  "id" INT PRIMARY KEY,
  "name" VARCHAR(255),
  "subtitle" VARCHAR(255),
  "icon_asset" VARCHAR(255),
  "is_on" BOOLEAN,
  "device_type" VARCHAR(50),
  "attributes" JSON,
  "room_id" INT
);

ALTER TABLE "ROOM" ADD FOREIGN KEY ("user_id") REFERENCES "CUSTOM_USER" ("id");

ALTER TABLE "DEVICE" ADD FOREIGN KEY ("room_id") REFERENCES "ROOM" ("id");