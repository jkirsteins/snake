<?php
  
$con = mysql_connect("localhost", "kirsis", "nAda52Ed") or die(mysql_error());
$db = mysql_select_db("kirsis_snake") or die(mysql_error());

$name = mysql_real_escape_string($_POST['name']);
$score = mysql_real_escape_string($_POST['score']);

$name = $_GET['name'];
$score = $_GET['score'];

if (!(trim($name) != "" && is_numeric($score)))
        die("Invalid values");


$result = mysql_query("INSERT INTO scores (created_at, score, name) VALUES (NOW(), '$score', '$name')");

if (!$result)
        die(mysql_error());


$result = mysql_query("SELECT * FROM scores ORDER BY score DESC LIMIT 5");
if (!$result)
        die(mysql_error());

$pos = 1;
while ($row = mysql_fetch_assoc($result))
        echo sprintf("#%d - %s - %s pts - %s\n", 
                $pos++, 
                $row['name'], 
                $row['score'], 
                $row['created_at']);

