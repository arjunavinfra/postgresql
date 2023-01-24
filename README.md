# postgresql
This repo will show you two methods of deploying PostgreSQL on Kubernetes - using a Helm chart or manually creating your configuration.


CREATE DATABASE ARJUN

\c arjun

CREATE TABLE persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

select * from Persons