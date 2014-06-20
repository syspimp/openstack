<?php
# this will remove any servers from puppet stored configs
# that havent checked in in X days

$mysqlhost='localhost';
$mysqluser='puppet';
$mysqlpass='puppet';
$mysqldb='puppet';

$daystokeep=7;

$sql='SELECT * FROM  `hosts` WHERE updated_at < DATE_SUB( NOW( ) , INTERVAL '.$daystokeep.' DAY );';
$link = mysqli_connect($mysqlhost, $mysqluser, $mysqlpass, $mysqldb);


if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
}

# gotta get the host id
if ($result = mysqli_query($link, $sql)) {
    //printf("Select returned %d rows.\n", mysqli_num_rows($result));
    //var_dump($result);
            while ($row = mysqli_fetch_row($result)) {
                //printf("%s\n", $row[0]);
                $hostids[] = $row[0];
            }
            @mysqli_free_result($result);
}



# now we use hostid to get the resources to delete
foreach($hostids as $hostid)
{
  $sql='SELECT * FROM `fact_values` WHERE (`fact_values`.host_id = '.$hostid.');';
  if ($result = mysqli_query($link, $sql)) {
    //printf("Select returned %d rows.\n", mysqli_num_rows($result));
    //var_dump($result);
    while ($row = mysqli_fetch_row($result)) {
                //printf("%s\n", $row[0]);
                $factids[] = $row[0];
    }
    @mysqli_free_result($result);

    foreach($factids as $factid)
    {
      $sql='DELETE FROM `fact_values` WHERE `id` = '.$factid.' limit 1;';
      if ($result = mysqli_query($link, $sql)) {
            @mysqli_free_result($result);
      }
    }
  }

  $sql='SELECT * FROM `resources` WHERE (`resources`.host_id = '.$hostid.');';
  if ($result = mysqli_query($link, $sql)) {
    //printf("Select returned %d rows.\n", mysqli_num_rows($result));
    //var_dump($result);
    while ($row = mysqli_fetch_row($result)) {
      //printf("%s\n", $row[0]);
      $resourceids[] = $row[0];
    }
    @mysqli_free_result($result);

    foreach($resourceids as $resourceid)
    {
      $sql='SELECT * FROM `param_values` WHERE (`param_values`.resource_id = '.$resourceid.');';
      if ($result = mysqli_query($link, $sql)) {
        //printf("Select returned %d rows.\n", mysqli_num_rows($result));
        while ($row = mysqli_fetch_row($result)) {
          //printf("%s\n", $row[0]);
          $paramids[] = $row[0];
        }
        foreach($paramids as $paramid)
        {
          $sql='DELETE FROM `param_values` WHERE `id` = '.$paramid.' limit 1;';
          if ($result = mysqli_query($link, $sql)) {
            @mysqli_free_result($result);
          }
        }
      }
      $sql='SELECT * FROM `resource_tags` WHERE (`resource_tags`.resource_id = '.$resourceid.');';
      if ($result = mysqli_query($link, $sql)) {
        //printf("Select returned %d rows.\n", mysqli_num_rows($result));
        while ($row = mysqli_fetch_row($result)) {
          //printf("%s\n", $row[0]);
          $tagids[] = $row[0];
        }
        foreach($tagids as $tagid)
        {
          $sql='DELETE FROM `resource_tags` WHERE `id` = '.$tagid.' limit 1;';
          if ($result = mysqli_query($link, $sql)) {
            @mysqli_free_result($result);
          }
        }
      }
      $sql='DELETE FROM `resources` WHERE `id` = '.$resourceid.';';
      if ($result = mysqli_query($link, $sql)) {
        @mysqli_free_result($result);
      }
    }
  }
  $sql='DELETE FROM `hosts` WHERE `id` = '.$hostid.';';
  if ($result = mysqli_query($link, $sql)) {
    @mysqli_free_result($result);
  }
}

mysqli_close($link);


