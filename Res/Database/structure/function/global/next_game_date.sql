UPDATE global
SET game_date = DATE(game_date, '+1 days')
WHERE global_id = 1;