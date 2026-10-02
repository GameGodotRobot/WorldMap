INSERT INTO global(
global_id,
game_date,
player_country_id
)
SELECT 1 global_id,
       column1,
       column2
FROM _params
ON CONFLICT(global_id)
DO UPDATE
SET game_date = excluded.game_date,
    player_country_id = excluded.player_country_id;