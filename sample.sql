-- CREATE DATABASE recipes_database;
-- USE recipes_database;

CREATE TABLE recipes (
  recipe_id INT NOT NULL,
  recipe_name VARCHAR(30) NOT NULL,
  PRIMARY KEY (recipe_id),
  UNIQUE (recipe_name)
);

INSERT INTO recipes 
    (recipe_id, recipe_name) 
VALUES 
    (1,"Tacos"),
    (2,"Tomato Soup"),
    (3,"Grilled Cheese");

CREATE TABLE ingredients (
  ingredient_id INT NOT NULL, 
  ingredient_name VARCHAR(30) NOT NULL,
  ingredient_price INT NOT NULL,
  PRIMARY KEY (ingredient_id),  
  UNIQUE (ingredient_name)
);

INSERT INTO ingredients
    (ingredient_id, ingredient_name, ingredient_price)
VALUES 
    (1, "Beef", 5),
    (2, "Lettuce", 1),
    (3, "Tomatoes", 2),
    (4, "Taco Shell", 2),
    (5, "Cheese", 3),
    (6, "Milk", 1),
    (7, "Bread", 2);


CREATE TABLE recipe_ingredients (
  recipe_id int NOT NULL, 
  ingredient_id INT NOT NULL, 
  amount INT NOT NULL,
  PRIMARY KEY (recipe_id,ingredient_id)
);

INSERT INTO recipe_ingredients 
    (recipe_id, ingredient_id, amount)
VALUES
    (1,1,1),
    (1,2,2),
    (1,3,2),
    (1,4,3),
    (1,5,1),
    (2,3,2),
    (2,6,1),
    (3,5,1),
    (3,7,2);

CREATE TABLE recipes (
  recipe_id INT NOT NULL AUTO_INCREMENT,
  recipe_name VARCHAR(30) NOT NULL,
  PRIMARY KEY (recipe_id),
  UNIQUE (recipe_name)
);

INSERT INTO recipes 
    (recipe_name) 
VALUES 
    ("Tacos"),
    ("Tomato Soup"),
    ("Grilled Cheese");


