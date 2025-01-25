WITH last_season AS (
    SELECT * FROM players
    WHERE current_season = 1997

), this_season AS (
     SELECT * FROM player_seasons
    WHERE season = 1998
)
INSERT INTO players
SELECT
        COALESCE(ls.player_name, ts.player_name) as player_name,
        COALESCE(ls.height, ts.height) as height,
        COALESCE(ls.college, ts.college) as college,
        COALESCE(ls.country, ts.country) as country,
        COALESCE(ls.draft_year, ts.draft_year) as draft_year,
        COALESCE(ls.draft_round, ts.draft_round) as draft_round,
        COALESCE(ls.draft_number, ts.draft_number)
            as draft_number,
        COALESCE(ls.seasons,
            ARRAY[]::season_stats[]
            ) || CASE WHEN ts.season IS NOT NULL THEN
                ARRAY[ROW(
                ts.season,
                ts.pts,
                ts.ast,
                ts.reb, ts.weight)::season_stats]
                ELSE ARRAY[]::season_stats[] END
            as seasons,
         CASE
             WHEN ts.season IS NOT NULL THEN
                 (CASE WHEN ts.pts > 20 THEN 'star'
                    WHEN ts.pts > 15 THEN 'good'
                    WHEN ts.pts > 10 THEN 'average'
                    ELSE 'bad' END)::scoring_class
             ELSE ls.scoring_class
         END as scoring_class,
         ts.season IS NOT NULL as is_active,
         1998 AS current_season

    FROM last_season ls
    FULL OUTER JOIN this_season ts
    ON ls.player_name = ts.player_name

-- -- Via Cursor
-- DO $$
-- DECLARE
--     -- Cursor to iterate over seasons
--     season_cursor CURSOR FOR
--         SELECT DISTINCT season FROM player_seasons ORDER BY season;

--     -- Variables to hold dynamic seasons
--     ThisSeason INT;
--     LastSeason INT;

-- BEGIN
--     -- Open the cursor
--     OPEN season_cursor;

--     -- Fetch the first season
--     FETCH season_cursor INTO ThisSeason;

--     -- Loop through the seasons
--     WHILE FOUND LOOP
--         -- Calculate the next season
--         LastSeason := ThisSeason - 1;

--         -- Perform the logic for the current season and next season
--         WITH last_season AS (
--             SELECT * FROM players
--             WHERE current_season = LastSeason 
-- 			-- AND player_name = 'Michael Jordan'
--         ), this_season AS (
--             SELECT * FROM player_seasons
--             WHERE season = ThisSeason
-- 			-- AND player_name = 'Michael Jordan'
--         )
--         INSERT INTO players
--         SELECT
--             COALESCE(ls.player_name, ts.player_name) as player_name,
--             COALESCE(ls.height, ts.height) as height,
--             COALESCE(ls.college, ts.college) as college,
--             COALESCE(ls.country, ts.country) as country,
--             COALESCE(ls.draft_year, ts.draft_year) as draft_year,
--             COALESCE(ls.draft_round, ts.draft_round) as draft_round,
--             COALESCE(ls.draft_number, ts.draft_number) as draft_number,
--             COALESCE(ls.season_stats,
--                 ARRAY[]::season_stats[]
--                 ) || CASE WHEN ts.season IS NOT NULL THEN
--                     ARRAY[ROW(
--                     ts.season,
--                     ts.pts,
--                     ts.ast,
--                     ts.reb, ts.weight)::season_stats]
--                     ELSE ARRAY[]::season_stats[] END as season_stats,
-- 			-- CASE WHEN ts.season IS NOT NULL THEN TRUE ELSE FALSE END as is_active,
--             COALESCE(ts.season, ls.current_season + 1) AS current_season,
--             CASE
--                 WHEN ts.season IS NOT NULL THEN
--                     (CASE WHEN ts.pts > 20 THEN 'Star'
--                         WHEN ts.pts > 15 THEN 'Good'
--                         WHEN ts.pts > 10 THEN 'Average'
--                         ELSE 'Bad' END)::scoring_class
--                 ELSE ls.scoring_class
--             END as scoring_class,
--             CASE WHEN ts.season IS NOT NULL THEN 0 ELSE COALESCE(ls.year_since_last_season, 0) + 1 END as yearsincelastseason
--         FROM last_season ls
--         FULL OUTER JOIN this_season ts
--         ON ls.player_name = ts.player_name;

--         -- Fetch the next season
--         FETCH season_cursor INTO ThisSeason;
--     END LOOP;

--     -- Close the cursor
--     CLOSE season_cursor;
-- END $$;


