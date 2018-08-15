----------------------------------------------------------------- 
----------------------------------------------------------------- 
CREATE TABLE events_log
(
    event_date TIMESTAMP NOT NULL,
    device_id VARCHAR(20) NOT NULL,
    event_id BIGINT,
    event_value FLOAT DEFAULT NULL ,
    params JSON DEFAULT NULL
    FOREIGN KEY (event_id) REFERENCES events (id),
    FOREIGN KEY (device_id) REFERENCES users (device_id)
);

-- Se asume que existe una tabla users con la primary key device_id.

----------------------------------------------------------------- 
----------------------------------------------------------------- 
CREATE TABLE events
(
  id          BIGINT(20) PRIMARY KEY NOT NULL,
  name        VARCHAR(100)           NOT NULL,
  description VARCHAR(255)           NOT NULL
)
;

-----------------------1------------------------------------------ 
 -- Populating the events table
 ----------------------------------------------------------------- 
 
INSERT INTO events (id,name,description) VALUES (1, "purchase", "Description");
INSERT INTO events (id,name,description) VALUES (2, "search", "Description");
INSERT INTO events (id,name,description) VALUES (3, "app_open", "Description");

----------------------------------------------------------------- 
-- Populating the events_log table
----------------------------------------------------------------- 

INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2017-09-13 12:01:00","aed-355-dg25", 3,NULL,NULL );
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2017-09-13 12:05:00","aed-355-dg25", 2,NULL,"{“term”: [“lamp”, “blue”]} ");
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2017-09-13 12:15:00 ","aed-355-dg25", 1,2.01,"{“item_name”: “TABLE”} ");
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2018-08-13 12:01:00","aed-355-dg25", 3,NULL,NULL );
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2018-08-13 12:01:00","aed-355-dg25", 1,NULL,NULL );
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2018-08-15 12:01:00","Fed-355-dg25", 1,3.6,NULL );
INSERT INTO events_log (event_date, device_id, event_id, event_value, params) VALUE ("2018-08-14 12:01:00","Xed-355-dg25", 1,5,NULL );


----------------------------------------------------------------- 
-------------- SQL 1---------------------------------------------
----------------------------------------------------------------- 
SELECT device_id, avg(event_value/Total) as Av
FROM (
    SELECT
        device_id,
        IF(event_value IS NULL, 0, event_value) event_value,
        (SELECT SUM(event_value)
         FROM events_log
         WHERE DATE(event_date) BETWEEN ((CURRENT_DATE) - INTERVAL 7 DAY) AND CURRENT_DATE() AND
               events_log.event_id = 1) AS Total
    FROM events_log
    WHERE DATE(event_date) BETWEEN ((CURRENT_DATE) - INTERVAL 7 DAY) AND CURRENT_DATE()
          AND events_log.event_id = 1
) purchasers
GROUP BY  device_id
ORDER BY Av DESC
LIMIT 10
;
----------------------------------------------------------------- 
-------------- SQL 2---------------------------------------------
----------------------------------------------------------------- 

SELECT AVG(time_to_sec(timediff(app_open_events.event_date,purchased.event_date))/60) AVG_DELTA_MINUTES
    FROM
    (select event_date, device_id FROM events_log where event_id=3 ) purchased
    join
    (select event_date, device_id FROM events_log
    where event_id=1
    ) app_open_events
    on purchased.device_id =  app_open_events.device_id
    where time_to_sec(timediff(app_open_events.event_date,purchased.event_date))/60 < 30

;
