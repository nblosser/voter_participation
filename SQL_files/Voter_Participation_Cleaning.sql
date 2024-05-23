--------------------------------------------------------------------------------
/*				                 Cleaning eavs2014           		  		          */
---------------------------------------------------------------------------------- 

/* Remove all other comment columns. These explanations are not present in large enough
quantities to be aggregated individually. We will simply keep 'other' entries as 'other' 
with no further comment for further analysis. */

ALTER TABLE eavs2014
DROP other1_comment_removed,
DROP other2_comment_removed,
DROP other3_comment_removed,
DROP other4_comment_removed,
DROP other1_comment_civilian,
DROP other2_comment_civilian,
DROP other3_comment_civilian,
DROP other4_comment_civilian,
DROP other5_comment_civilian,
DROP other6_comment_civilian,
DROP other7_comment_civilian,
DROP other1_comment_participated,
DROP other2_comment_participated;


/* Remove active_inactive column. It is not in the other tables and it is not
pertinent for analysis. */

ALTER TABLE eavs2014
DROP active_inactive;


/* According to the codebook, 
-9999999 indicates data not available
-8888888 indicates data not applicable
null indicates no response

Since we are primarily assessing voter participation, we will eliminate records with these
3 missing values from registered_eligible_total and participated_total. We will still have
sufficient data to analyze after dropping these records, and not having this data
renders them fairly useless for this analysis. */

DELETE from eavs2014 
WHERE registered_eligible_total IS NULL or registered_eligible_total = '-999999';

DELETE from eavs2014 
WHERE participated_total IS NULL or participated_total = '-999999';

SELECT * FROM eavs2014 LIMIT 20;
SELECT DISTINCT registered_eligible_total FROM eavs2014 ORDER BY registered_eligible_total;
SELECT DISTINCT participated_total FROM eavs2014 ORDER BY participated_total;



/* For the remaining variables in this dataset, we will treat '-888888' (not applicable) as 0 and
'-999999' (not available) as null. */


-- f1 - replace all '-888888' in table with '0'

create or replace function f1(_table text,_oldVal text,_newVal text) returns void as 
$$
declare 
rw record;
begin
for rw in 
    select 'UPDATE '||$1||' SET '||C.COLUMN_NAME||' = REPLACE ('||C.COLUMN_NAME||','''||$2||''','''||$3||'''); ' QRY
    FROM (select column_name from information_schema.columns where table_schema='public' and table_name =$1)c
loop
    EXECUTE rw.QRY;
end loop;
end;
$$language plpgsql;


SELECT f1('eavs2014','-888888','0');
SELECT * FROM eavs2014 WHERE fipscode = '4839300000';



-- f2 - replace all '-999999' in table with NULL

CREATE OR REPLACE FUNCTION f2(_table text, _oldVal text, _newVal text) RETURNS void LANGUAGE plpgsql AS
$FUNC$
<<local>>
DECLARE
  criteria         text;
  match_phrase     text;
  set_list         text;
  update_statement text;
BEGIN
  IF _oldVal IS NOT DISTINCT FROM _newVal THEN
    RETURN;
  END IF;
  
  match_phrase = CASE WHEN _oldVal IS NULL THEN 'IS NULL' ELSE FORMAT($$= %L$$, _oldVal) END;

  SELECT STRING_AGG(FORMAT($$%1$I = CASE WHEN %1$I %2$s THEN %3$s ELSE %1$I END$$,
                           c.column_name,
                           local.match_phrase,
                           CASE WHEN f2._newVal IS NULL THEN 'NULL' ELSE QUOTE_LITERAL(f2._newVal) END),
                    ', ' ORDER BY c.ordinal_position),
         STRING_AGG(FORMAT($$%1$I %2$s$$, c.column_name, local.match_phrase),
                    ' OR ' ORDER BY c.ordinal_position)
    INTO set_list, criteria
    FROM information_schema.columns c
    WHERE c.table_schema = CURRENT_SCHEMA()
      AND c.table_name = f2._table
      AND c.data_type IN ('char', 'character', 'character varying', 'text');
  
  update_statement = FORMAT($$UPDATE %1$I SET %2$s WHERE %3$s;$$, _table, set_list, criteria);
  
  RAISE NOTICE 'Update statement: %', update_statement;
  
  EXECUTE update_statement;
END;
$FUNC$;


SELECT f2('eavs2014','-999999', NULL);
SELECT * FROM eavs2014 WHERE fipscode = '4106900000';




/* Casting all numeric columns as int. */

ALTER TABLE eavs2014
    ALTER COLUMN registered_eligible_total TYPE int USING registered_eligible_total::int,
    ALTER COLUMN active_registered_total TYPE int USING active_registered_total::int,
	ALTER COLUMN inactive_registered_total TYPE int USING inactive_registered_total::int,
	ALTER COLUMN same_day_registration_total TYPE int USING same_day_registration_total::int,
	ALTER COLUMN voters_removed_rolls_total TYPE int USING voters_removed_rolls_total::int,
	ALTER COLUMN voters_moved_removed TYPE int USING voters_moved_removed::int,
	ALTER COLUMN voters_died_removed TYPE int USING voters_died_removed::int,
	ALTER COLUMN voter_felony_removed TYPE int USING voter_felony_removed::int,
	ALTER COLUMN longterm_inactive_removed TYPE int USING longterm_inactive_removed::int,
	ALTER COLUMN mentally_incompetent_removed TYPE int USING mentally_incompetent_removed::int,
	ALTER COLUMN voter_request_removed TYPE int USING voter_request_removed::int,
	ALTER COLUMN other1_removed TYPE int USING other1_removed::int,
	ALTER COLUMN other2_removed TYPE int USING other2_removed::int,
	ALTER COLUMN other3_removed TYPE int USING other3_removed::int,
	ALTER COLUMN other4_removed TYPE int USING other4_removed::int,
	ALTER COLUMN absentee_uocava_total TYPE int USING absentee_uocava_total::int,
	ALTER COLUMN uocava_rejected TYPE int USING uocava_rejected::int,
	ALTER COLUMN missed_deadline_uocava TYPE int USING missed_deadline_uocava::int,
	ALTER COLUMN voter_signature_problem_uocava TYPE int USING voter_signature_problem_uocava::int,
	ALTER COLUMN no_postmark_uocava TYPE int USING no_postmark_uocava::int,
	ALTER COLUMN other_uocava TYPE int USING other_uocava::int,
	ALTER COLUMN absentee_civilian_total TYPE int USING absentee_civilian_total::int,
	ALTER COLUMN civilian_absentee_counted TYPE int USING civilian_absentee_counted::int,
	ALTER COLUMN civilian_absentee_rejected TYPE int USING civilian_absentee_rejected::int,
	ALTER COLUMN missed_deadline_civilian TYPE int USING missed_deadline_civilian::int,
	ALTER COLUMN no_voter_signature_civilian TYPE int USING no_voter_signature_civilian::int,
	ALTER COLUMN no_witness_signature_civilian TYPE int USING no_witness_signature_civilian::int,
	ALTER COLUMN non_matching_signature_civilian TYPE int USING non_matching_signature_civilian::int,
	ALTER COLUMN no_official_signature_civilian TYPE int USING no_official_signature_civilian::int,
	ALTER COLUMN unofficial_envelope_civilian TYPE int USING unofficial_envelope_civilian::int,
	ALTER COLUMN ballot_missing_civilian TYPE int USING ballot_missing_civilian::int,
	ALTER COLUMN envelope_unsealed_civilian TYPE int USING envelope_unsealed_civilian::int,
	ALTER COLUMN no_address_envelope_civilian TYPE int USING no_address_envelope_civilian::int,
	ALTER COLUMN multiple_ballots_envelope_civilian TYPE int USING multiple_ballots_envelope_civilian::int,
	ALTER COLUMN voter_deceased_civilian TYPE int USING voter_deceased_civilian::int,
	ALTER COLUMN voted_in_person_civilian TYPE int USING voted_in_person_civilian::int,
	ALTER COLUMN improper_id_civilian TYPE int USING improper_id_civilian::int,
	ALTER COLUMN no_ballot_application_civilian TYPE int USING no_ballot_application_civilian::int,
	ALTER COLUMN other1_civilian TYPE int USING other1_civilian::int,
	ALTER COLUMN other2_civilian TYPE int USING other2_civilian::int,
	ALTER COLUMN other3_civilian TYPE int USING other3_civilian::int,
	ALTER COLUMN other4_civilian TYPE int USING other4_civilian::int,
	ALTER COLUMN other5_civilian TYPE int USING other5_civilian::int,
	ALTER COLUMN other6_civilian TYPE int USING other6_civilian::int,
	ALTER COLUMN other7_Civilian TYPE int USING other7_Civilian::int,
	ALTER COLUMN precincts_total TYPE int USING precincts_total::int,
	ALTER COLUMN polling_places_total TYPE int USING polling_places_total::int,
	ALTER COLUMN poll_workers_total TYPE int USING poll_workers_total::int,
	ALTER COLUMN provisional_ballot_total TYPE int USING provisional_ballot_total::int,
	ALTER COLUMN counted_full_provisional TYPE int USING counted_full_provisional::int,
	ALTER COLUMN counted_partial_provisional TYPE int USING counted_partial_provisional::int,
	ALTER COLUMN rejected_provisional TYPE int USING rejected_provisional::int,
	ALTER COLUMN participated_total TYPE int USING participated_total::int,
	ALTER COLUMN in_person_participated TYPE int USING in_person_participated::int,
	ALTER COLUMN uocava_absentee_participated TYPE int USING uocava_absentee_participated::int,
	ALTER COLUMN civilian_absentee_participated TYPE int USING civilian_absentee_participated::int,
	ALTER COLUMN provisional_participated TYPE int USING provisional_participated::int,
	ALTER COLUMN early_vote_participated TYPE int USING early_vote_participated::int,
	ALTER COLUMN mail_jurisdiction_participated TYPE int USING mail_jurisdiction_participated::int,
	ALTER COLUMN other1_participated TYPE int USING other1_participated::int,
	ALTER COLUMN other2_participated TYPE int USING other2_participated::int;




/* Combining the numerous "other" columns in their respective categories by creat one other 
column relevant to each "other" grouping, and filling it with the sum of the "others". For summing
step, null values will be treated as 0. Finally, the numerous "other" columns will be dropped. */


-- Create other_removed column and fill with sum of other1_removed through other4_removed.

ALTER TABLE eavs2014 ADD COLUMN other_removed int;
UPDATE eavs2014
SET other_removed = COALESCE(other1_removed,0) + COALESCE(other2_removed,0) 
+ COALESCE(other3_removed,0) + COALESCE(other4_removed,0)
RETURNING other_removed;


-- Create other_civilian column and fill with sum of other1_civilian through other7_civilian.

ALTER TABLE eavs2014 ADD COLUMN other_civilian int;
UPDATE eavs2014
SET other_civilian = COALESCE(other1_civilian,0) + COALESCE(other2_civilian,0) 
+ COALESCE(other3_civilian,0) + COALESCE(other4_civilian,0) + COALESCE(other5_civilian,0) 
+ COALESCE(other6_civilian,0) + COALESCE(other7_civilian,0)
RETURNING other_civilian;


-- Create other_participated column and fill with sum of other1_participated through other2_participated.

ALTER TABLE eavs2014 ADD COLUMN other_participated int;
UPDATE eavs2014
SET other_participated = COALESCE(other1_participated,0) + COALESCE(other2_participated,0)
RETURNING other_participated;


-- Drop various other fields used to create the combined other fields

ALTER TABLE eavs2014
DROP other1_removed,
DROP other2_removed,
DROP other3_removed,
DROP other4_removed,
DROP other1_civilian,
DROP other2_civilian,
DROP other3_civilian,
DROP other4_civilian,
DROP other5_civilian,
DROP other6_civilian,
DROP other7_civilian,
DROP other1_participated,
DROP other2_participated;



/* Combining similar civilian_absentee rejection reason columns to reduce by summing similar
columns into new combine column and deleting combined columns. */


-- Create signature_issue_civilian columns and fill with sum of no_voter_signature_civilian, 
-- no_witness_signature_civilian, non_matching_signature_civilian, no_official_signature_civilian

ALTER TABLE eavs2014 ADD COLUMN signature_issue_civilian int;
UPDATE eavs2014
SET signature_issue_civilian = COALESCE(no_voter_signature_civilian,0)
+ COALESCE(no_witness_signature_civilian,0) + COALESCE(non_matching_signature_civilian,0)
+ COALESCE(no_official_signature_civilian,0)
RETURNING signature_issue_civilian;


-- Create envelope_issue_civilian columns and fill with sum of unofficial_envelope_civilian, 
-- envelope_unsealed_civilian, no_address_envelope_civilian, multiple_ballots_envelope_civilian

ALTER TABLE eavs2014 ADD COLUMN envelope_issue_civilian int;
UPDATE eavs2014
SET envelope_issue_civilian = COALESCE(unofficial_envelope_civilian,0)
+ COALESCE(envelope_unsealed_civilian,0) + COALESCE(no_address_envelope_civilian,0)
+ COALESCE(multiple_ballots_envelope_civilian,0)
RETURNING envelope_issue_civilian;


-- Drop columns used to create the combined civilian_absentee rejection reason columns

ALTER TABLE eavs2014
DROP no_voter_signature_civilian,
DROP no_witness_signature_civilian,
DROP non_matching_signature_civilian,
DROP no_official_signature_civilian,
DROP unofficial_envelope_civilian,
DROP envelope_unsealed_civilian,
DROP no_address_envelope_civilian,
DROP multiple_ballots_envelope_civilian;

ALTER TABLE eavs2014
DROP same_day_comment;


SELECT * FROM eavs2014;

SELECT COUNT(*) FROM information_schema.columns
WHERE table_name='eavs2014';



--------------------------------------------------------------------------------
/*				                 Cleaning eavs2016           		  		          */
---------------------------------------------------------------------------------- 

SELECT * FROM eavs2016;

/* Remove all other comment columns. These explanations are not present in large enough
quantities to be aggregated individually. We will simply keep 'other' entries as 'other' 
with no further comment for further analysis. */

ALTER TABLE eavs2016
DROP other1_comment_removed,
DROP other2_comment_removed,
DROP other3_comment_removed,
DROP other4_comment_removed,
DROP other1_comment_civilian,
DROP other2_comment_civilian,
DROP other3_comment_civilian,
DROP other4_comment_civilian,
DROP other5_comment_civilian,
DROP other6_comment_civilian,
DROP other7_comment_civilian,
DROP other8_comment_civilian,
DROP other1_comment_participated,
DROP other2_comment_participated,
DROP other3_comment_participated;


/* Remove active_inactive column. It is not in the other tables and it is not
pertinent for analysis. */

ALTER TABLE eavs2016
DROP active_inactive;


/* According to the codebook, 
-9999999 indicates data not available
-8888888 indicates data not applicable
null indicates no response

Since we are primarily assessing voter participation, we will eliminate records with these
3 missing values from registered_eligible_total and participated_total. We will still have
sufficient data to analyze after dropping these records, and not having this data
renders them fairly useless for this analysis. */

DELETE from eavs2016 
WHERE registered_eligible_total IS NULL or registered_eligible_total = '-999999: Data Not Available';

DELETE from eavs2016 
WHERE participated_total IS NULL or participated_total = '-999999: Data Not Available';

SELECT * FROM eavs2016 LIMIT 20;
SELECT DISTINCT registered_eligible_total FROM eavs2016 ORDER BY registered_eligible_total;
SELECT DISTINCT participated_total FROM eavs2016 ORDER BY participated_total;



/* For the remaining variables in this dataset, we will treat '-888888' (not applicable) as 0 and
'-999999' (not available) as null. */


-- f1 - replace all '-888888' in table with '0'

SELECT f1('eavs2016','-888888: Not Applicable','0');
SELECT * FROM eavs2016 WHERE fipscode = '4839300000';



-- f2 - replace all '-999999' in table with NULL

SELECT f2('eavs2016','-999999: Data Not Available', NULL);
SELECT * FROM eavs2016 WHERE fipscode = '4839300000';




/* Casting all numeric columns as int. */

ALTER TABLE eavs2016
    ALTER COLUMN registered_eligible_total TYPE int USING registered_eligible_total::int,
    ALTER COLUMN active_registered_total TYPE int USING active_registered_total::int,
	ALTER COLUMN inactive_registered_total TYPE int USING inactive_registered_total::int,
	ALTER COLUMN same_day_registration_total TYPE int USING same_day_registration_total::int,
	ALTER COLUMN voters_removed_rolls_total TYPE int USING voters_removed_rolls_total::int,
	ALTER COLUMN voters_moved_removed TYPE int USING voters_moved_removed::int,
	ALTER COLUMN voters_died_removed TYPE int USING voters_died_removed::int,
	ALTER COLUMN voter_felony_removed TYPE int USING voter_felony_removed::int,
	ALTER COLUMN longterm_inactive_removed TYPE int USING longterm_inactive_removed::int,
	ALTER COLUMN mentally_incompetent_removed TYPE int USING mentally_incompetent_removed::int,
	ALTER COLUMN voter_request_removed TYPE int USING voter_request_removed::int,
	ALTER COLUMN other1_removed TYPE int USING other1_removed::int,
	ALTER COLUMN other2_removed TYPE int USING other2_removed::int,
	ALTER COLUMN other3_removed TYPE int USING other3_removed::int,
	ALTER COLUMN other4_removed TYPE int USING other4_removed::int,
	ALTER COLUMN absentee_uocava_total TYPE int USING absentee_uocava_total::int,
	ALTER COLUMN uocava_rejected TYPE int USING uocava_rejected::int,
	ALTER COLUMN missed_deadline_uocava TYPE int USING missed_deadline_uocava::int,
	ALTER COLUMN voter_signature_problem_uocava TYPE int USING voter_signature_problem_uocava::int,
	ALTER COLUMN no_postmark_uocava TYPE int USING no_postmark_uocava::int,
	ALTER COLUMN other_uocava TYPE int USING other_uocava::int,
	ALTER COLUMN absentee_civilian_total TYPE int USING absentee_civilian_total::int,
	ALTER COLUMN civilian_absentee_counted TYPE int USING civilian_absentee_counted::int,
	ALTER COLUMN civilian_absentee_rejected TYPE int USING civilian_absentee_rejected::int,
	ALTER COLUMN missed_deadline_civilian TYPE int USING missed_deadline_civilian::int,
	ALTER COLUMN no_voter_signature_civilian TYPE int USING no_voter_signature_civilian::int,
	ALTER COLUMN no_witness_signature_civilian TYPE int USING no_witness_signature_civilian::int,
	ALTER COLUMN non_matching_signature_civilian TYPE int USING non_matching_signature_civilian::int,
	ALTER COLUMN no_official_signature_civilian TYPE int USING no_official_signature_civilian::int,
	ALTER COLUMN unofficial_envelope_civilian TYPE int USING unofficial_envelope_civilian::int,
	ALTER COLUMN ballot_missing_civilian TYPE int USING ballot_missing_civilian::int,
	ALTER COLUMN envelope_unsealed_civilian TYPE int USING envelope_unsealed_civilian::int,
	ALTER COLUMN no_address_envelope_civilian TYPE int USING no_address_envelope_civilian::int,
	ALTER COLUMN multiple_ballots_envelope_civilian TYPE int USING multiple_ballots_envelope_civilian::int,
	ALTER COLUMN voter_deceased_civilian TYPE int USING voter_deceased_civilian::int,
	ALTER COLUMN voted_in_person_civilian TYPE int USING voted_in_person_civilian::int,
	ALTER COLUMN improper_id_civilian TYPE int USING improper_id_civilian::int,
	ALTER COLUMN no_ballot_application_civilian TYPE int USING no_ballot_application_civilian::int,
	ALTER COLUMN other1_civilian TYPE int USING other1_civilian::int,
	ALTER COLUMN other2_civilian TYPE int USING other2_civilian::int,
	ALTER COLUMN other3_civilian TYPE int USING other3_civilian::int,
	ALTER COLUMN other4_civilian TYPE int USING other4_civilian::int,
	ALTER COLUMN other5_civilian TYPE int USING other5_civilian::int,
	ALTER COLUMN other6_civilian TYPE int USING other6_civilian::int,
	ALTER COLUMN other7_Civilian TYPE int USING other7_Civilian::int,
	ALTER COLUMN other8_Civilian TYPE int USING other8_Civilian::int,
	ALTER COLUMN precincts_total TYPE int USING precincts_total::int,
	ALTER COLUMN polling_places_total TYPE int USING polling_places_total::int,
	ALTER COLUMN poll_workers_total TYPE int USING poll_workers_total::int,
	ALTER COLUMN provisional_ballot_total TYPE int USING provisional_ballot_total::int,
	ALTER COLUMN counted_full_provisional TYPE int USING counted_full_provisional::int,
	ALTER COLUMN counted_partial_provisional TYPE int USING counted_partial_provisional::int,
	ALTER COLUMN rejected_provisional TYPE int USING rejected_provisional::int,
	ALTER COLUMN participated_total TYPE int USING participated_total::int,
	ALTER COLUMN in_person_participated TYPE int USING in_person_participated::int,
	ALTER COLUMN uocava_absentee_participated TYPE int USING uocava_absentee_participated::int,
	ALTER COLUMN civilian_absentee_participated TYPE int USING civilian_absentee_participated::int,
	ALTER COLUMN provisional_participated TYPE int USING provisional_participated::int,
	ALTER COLUMN early_vote_participated TYPE int USING early_vote_participated::int,
	ALTER COLUMN mail_jurisdiction_participated TYPE int USING mail_jurisdiction_participated::int,
	ALTER COLUMN other1_participated TYPE int USING other1_participated::int,
	ALTER COLUMN other2_participated TYPE int USING other2_participated::int,
	ALTER COLUMN other3_participated TYPE int USING other3_participated::int;




/* Combining the numerous "other" columns in their respective categories by creat one other 
column relevant to each "other" grouping, and filling it with the sum of the "others". For summing
step, null values will be treated as 0. Finally, the numerous "other" columns will be dropped. */


-- Create other_removed column and fill with sum of other1_removed through other4_removed.

ALTER TABLE eavs2016 ADD COLUMN other_removed int;
UPDATE eavs2016
SET other_removed = COALESCE(other1_removed,0) + COALESCE(other2_removed,0) 
+ COALESCE(other3_removed,0) + COALESCE(other4_removed,0)
RETURNING other_removed;


-- Create other_civilian column and fill with sum of other1_civilian through other7_civilian.

ALTER TABLE eavs2016 ADD COLUMN other_civilian int;
UPDATE eavs2016
SET other_civilian = COALESCE(other1_civilian,0) + COALESCE(other2_civilian,0) 
+ COALESCE(other3_civilian,0) + COALESCE(other4_civilian,0) + COALESCE(other5_civilian,0) 
+ COALESCE(other6_civilian,0) + COALESCE(other7_civilian,0) + COALESCE(other8_civilian,0)
RETURNING other_civilian;


-- Create other_participated column and fill with sum of other1_participated through other2_participated.

ALTER TABLE eavs2016 ADD COLUMN other_participated int;
UPDATE eavs2016
SET other_participated = COALESCE(other1_participated,0) + COALESCE(other2_participated,0)
 + COALESCE(other3_participated,0)
RETURNING other_participated;


-- Drop various other fields used to create the combined other fields

ALTER TABLE eavs2016
DROP other1_removed,
DROP other2_removed,
DROP other3_removed,
DROP other4_removed,
DROP other1_civilian,
DROP other2_civilian,
DROP other3_civilian,
DROP other4_civilian,
DROP other5_civilian,
DROP other6_civilian,
DROP other7_civilian,
DROP other8_civilian,
DROP other1_participated,
DROP other2_participated,
DROP other3_participated;



/* Combining similar civilian_absentee rejection reason columns to reduce by summing similar
columns into new combine column and deleting combined columns. */


-- Create signature_issue_civilian columns and fill with sum of no_voter_signature_civilian, 
-- no_witness_signature_civilian, non_matching_signature_civilian, no_official_signature_civilian

ALTER TABLE eavs2016 ADD COLUMN signature_issue_civilian int;
UPDATE eavs2016
SET signature_issue_civilian = COALESCE(no_voter_signature_civilian,0)
+ COALESCE(no_witness_signature_civilian,0) + COALESCE(non_matching_signature_civilian,0)
+ COALESCE(no_official_signature_civilian,0)
RETURNING signature_issue_civilian;


-- Create envelope_issue_civilian columns and fill with sum of unofficial_envelope_civilian, 
-- envelope_unsealed_civilian, no_address_envelope_civilian, multiple_ballots_envelope_civilian

ALTER TABLE eavs2016 ADD COLUMN envelope_issue_civilian int;
UPDATE eavs2016
SET envelope_issue_civilian = COALESCE(unofficial_envelope_civilian,0)
+ COALESCE(envelope_unsealed_civilian,0) + COALESCE(no_address_envelope_civilian,0)
+ COALESCE(multiple_ballots_envelope_civilian,0)
RETURNING envelope_issue_civilian;


-- Drop columns used to create the combined civilian_absentee rejection reason columns

ALTER TABLE eavs2016
DROP no_voter_signature_civilian,
DROP no_witness_signature_civilian,
DROP non_matching_signature_civilian,
DROP no_official_signature_civilian,
DROP unofficial_envelope_civilian,
DROP envelope_unsealed_civilian,
DROP no_address_envelope_civilian,
DROP multiple_ballots_envelope_civilian;

ALTER TABLE eavs2016
DROP same_day_comment;


SELECT * FROM eavs2016;

SELECT COUNT(*) FROM information_schema.columns
WHERE table_name='eavs2016';



--------------------------------------------------------------------------------
/*				                 Cleaning eavs2018           		  		          */
---------------------------------------------------------------------------------- 

SELECT * FROM eavs2018;

/* Remove all other comment columns. These explanations are not present in large enough
quantities to be aggregated individually. We will simply keep 'other' entries as 'other' 
with no further comment for further analysis. */

ALTER TABLE eavs2018
DROP other1_comment_removed,
DROP other2_comment_removed,
DROP other3_comment_removed,
DROP other1_comment_civilian,
DROP other2_comment_civilian,
DROP other3_comment_civilian,
DROP other1_comment_participated;


/* According to the codebook, 
-99 or 'Data not available'  indicates data not available
-88 or 'Does not apply' indicates data not applicable
null indicates no response

Since we are primarily assessing voter participation, we will eliminate records with these
3 missing values from registered_eligible_total and participated_total. We will still have
sufficient data to analyze after dropping these records, and not having this data
renders them fairly useless for this analysis. */


DELETE from eavs2018
WHERE registered_eligible_total IS NULL 
or registered_eligible_total = '-99' or registered_eligible_total = 'Data not available';

DELETE from eavs2018 
WHERE participated_total IS NULL or participated_total = '88'
or participated_total = '-99' or participated_total = 'Data not available';

SELECT * FROM eavs2018 LIMIT 20;
SELECT DISTINCT registered_eligible_total FROM eavs2018 ORDER BY registered_eligible_total;
SELECT DISTINCT participated_total FROM eavs2018 ORDER BY participated_total;


/* For the remaining variables in this dataset, we will treat '-88' / 'Does not apply' as 0 and
'-99' / 'Data not available' as null. */


-- f1 - replace all '-888888' in table with '0'

SELECT f1('eavs2018','-88','0');
SELECT f1('eavs2018','Does not apply','0');
SELECT same_day_registration_total FROM eavs2018 WHERE fipscode = '100100000';
SELECT uocava_rejected FROM eavs2018 WHERE fipscode = '2300923200';


-- f2 - replace all '-999999' in table with NULL

SELECT f2('eavs2018','-99', NULL);
SELECT f2('eavs2018','Data not available', NULL);
SELECT * FROM eavs2018;
SELECT civilian_absentee_counted FROM eavs2018 WHERE fipscode = '508900000 ';



/* Casting all numeric columns as int. */

ALTER TABLE eavs2018
    ALTER COLUMN registered_eligible_total TYPE int USING registered_eligible_total::int,
    ALTER COLUMN active_registered_total TYPE int USING active_registered_total::int,
	ALTER COLUMN inactive_registered_total TYPE int USING inactive_registered_total::int,
	ALTER COLUMN same_day_registration_total TYPE int USING same_day_registration_total::int,
	ALTER COLUMN voters_removed_rolls_total TYPE int USING voters_removed_rolls_total::int,
	ALTER COLUMN voters_moved_removed TYPE int USING voters_moved_removed::int,
	ALTER COLUMN voters_died_removed TYPE int USING voters_died_removed::int,
	ALTER COLUMN voter_felony_removed TYPE int USING voter_felony_removed::int,
	ALTER COLUMN longterm_inactive_removed TYPE int USING longterm_inactive_removed::int,
	ALTER COLUMN mentally_incompetent_removed TYPE int USING mentally_incompetent_removed::int,
	ALTER COLUMN voter_request_removed TYPE int USING voter_request_removed::int,
	ALTER COLUMN other1_removed TYPE int USING other1_removed::int,
	ALTER COLUMN other2_removed TYPE int USING other2_removed::int,
	ALTER COLUMN other3_removed TYPE int USING other3_removed::int,
	ALTER COLUMN absentee_uocava_total TYPE int USING absentee_uocava_total::int,
	ALTER COLUMN uocava_rejected TYPE int USING uocava_rejected::int,
	ALTER COLUMN uocava_rejected_missed_deadline TYPE int USING uocava_rejected_missed_deadline::int,
	ALTER COLUMN uniformed_rejected_missed_deadline TYPE int USING uniformed_rejected_missed_deadline::int,
	ALTER COLUMN nonmilitary_rejected_missed_deadline TYPE int USING nonmilitary_rejected_missed_deadline::int,
	ALTER COLUMN uocava_rejected_voter_signature_problem TYPE int USING uocava_rejected_voter_signature_problem::int,
	ALTER COLUMN uniformed_rejected_voter_signature_problem TYPE int USING uniformed_rejected_voter_signature_problem::int,
	ALTER COLUMN nonmilitary_rejected_voter_signature_problem TYPE int USING nonmilitary_rejected_voter_signature_problem::int,
	ALTER COLUMN uocava_rejected_no_postmark TYPE int USING uocava_rejected_no_postmark::int,
	ALTER COLUMN uniformed_rejected_no_postmark TYPE int USING uniformed_rejected_no_postmark::int,
	ALTER COLUMN nonmilitary_rejected_no_postmark TYPE int USING nonmilitary_rejected_no_postmark::int,
	ALTER COLUMN other_uocava TYPE int USING other_uocava::int,
	ALTER COLUMN absentee_civilian_total TYPE int USING absentee_civilian_total::int,
	ALTER COLUMN civilian_absentee_counted TYPE int USING civilian_absentee_counted::int,
	ALTER COLUMN civilian_absentee_rejected TYPE int USING civilian_absentee_rejected::int,
	ALTER COLUMN missed_deadline_civilian TYPE int USING missed_deadline_civilian::int,
	ALTER COLUMN no_voter_signature_civilian TYPE int USING no_voter_signature_civilian::int,
	ALTER COLUMN no_witness_signature_civilian TYPE int USING no_witness_signature_civilian::int,
	ALTER COLUMN non_matching_signature_civilian TYPE int USING non_matching_signature_civilian::int,
	ALTER COLUMN no_official_signature_civilian TYPE int USING no_official_signature_civilian::int,
	ALTER COLUMN unofficial_envelope_civilian TYPE int USING unofficial_envelope_civilian::int,
	ALTER COLUMN ballot_missing_civilian TYPE int USING ballot_missing_civilian::int,
	ALTER COLUMN envelope_unsealed_civilian TYPE int USING envelope_unsealed_civilian::int,
	ALTER COLUMN no_address_envelope_civilian TYPE int USING no_address_envelope_civilian::int,
	ALTER COLUMN multiple_ballots_envelope_civilian TYPE int USING multiple_ballots_envelope_civilian::int,
	ALTER COLUMN voter_deceased_civilian TYPE int USING voter_deceased_civilian::int,
	ALTER COLUMN voted_in_person_civilian TYPE int USING voted_in_person_civilian::int,
	ALTER COLUMN improper_id_civilian TYPE int USING improper_id_civilian::int,
	ALTER COLUMN no_ballot_application_civilian TYPE int USING no_ballot_application_civilian::int,
	ALTER COLUMN other1_civilian TYPE int USING other1_civilian::int,
	ALTER COLUMN other2_civilian TYPE int USING other2_civilian::int,
	ALTER COLUMN other3_civilian TYPE int USING other3_civilian::int,
	ALTER COLUMN precincts_total TYPE int USING precincts_total::int,
	ALTER COLUMN polling_places_total TYPE int USING polling_places_total::int,
	ALTER COLUMN poll_workers_total TYPE int USING poll_workers_total::int,
	ALTER COLUMN provisional_ballot_total TYPE int USING provisional_ballot_total::int,
	ALTER COLUMN counted_full_provisional TYPE int USING counted_full_provisional::int,
	ALTER COLUMN counted_partial_provisional TYPE int USING counted_partial_provisional::int,
	ALTER COLUMN rejected_provisional TYPE int USING rejected_provisional::int,
	ALTER COLUMN participated_total TYPE int USING participated_total::int,
	ALTER COLUMN in_person_participated TYPE int USING in_person_participated::int,
	ALTER COLUMN uocava_absentee_participated TYPE int USING uocava_absentee_participated::int,
	ALTER COLUMN civilian_absentee_participated TYPE int USING civilian_absentee_participated::int,
	ALTER COLUMN provisional_participated TYPE int USING provisional_participated::int,
	ALTER COLUMN early_vote_participated TYPE int USING early_vote_participated::int,
	ALTER COLUMN mail_jurisdiction_participated TYPE int USING mail_jurisdiction_participated::int,
	ALTER COLUMN other1_participated TYPE int USING other1_participated::int;



/* This dataset parsed out missed_deadline_uocava, voter_signature_problem_uocava, 
and no_postmark_uocava into subcategories of uocava, uniformed, and nonmilitary. This was the 
only year that did this, so we will combine these subcategories into the same three categories
that exist in the other years */


-- Create missed_deadline_uocava column and fill with sum of uocava_rejected_missed_deadline, 
-- uniformed_rejected_missed_deadline, and nonmilitary_rejected_missed_deadline.

ALTER TABLE eavs2018 ADD COLUMN missed_deadline_uocava int;
UPDATE eavs2018
SET missed_deadline_uocava = COALESCE(uocava_rejected_missed_deadline,0) 
+ COALESCE(uniformed_rejected_missed_deadline,0) + COALESCE(nonmilitary_rejected_missed_deadline,0)
RETURNING uocava_rejected_missed_deadline, uniformed_rejected_missed_deadline, 
nonmilitary_rejected_missed_deadline, missed_deadline_uocava;


-- Create voter_signature_problem_uocava column and fill with sum of 
-- uocava_rejected_voter_signature_problem, uniformed_rejected_voter_signature_problem, 
-- and nonmilitary_rejected_voter_signature_problem

ALTER TABLE eavs2018 ADD COLUMN voter_signature_problem_uocava int;
UPDATE eavs2018
SET voter_signature_problem_uocava = COALESCE(uocava_rejected_voter_signature_problem,0) 
+ COALESCE(uniformed_rejected_voter_signature_problem,0) 
+ COALESCE(nonmilitary_rejected_voter_signature_problem,0)
RETURNING uocava_rejected_voter_signature_problem, uniformed_rejected_voter_signature_problem, 
nonmilitary_rejected_voter_signature_problem, voter_signature_problem_uocava;


-- Create missed_deadline_uocava column and fill with sum of uocava_rejected_no_postmark, 
-- uniformed_rejected_no_postmark, and nonmilitary_rejected_no_postmark

ALTER TABLE eavs2018 ADD COLUMN no_postmark_uocava int;
UPDATE eavs2018
SET no_postmark_uocava = COALESCE(uocava_rejected_no_postmark,0) 
+ COALESCE(uniformed_rejected_no_postmark,0) + COALESCE(nonmilitary_rejected_no_postmark,0)
RETURNING uocava_rejected_no_postmark, uniformed_rejected_no_postmark, 
nonmilitary_rejected_no_postmark, no_postmark_uocava;


-- Drop fields used to create combined missed_deadline_uocava, voter_signature_problem_uocava,
-- and no_postmark_uocava fields.

ALTER TABLE eavs2018
DROP uocava_rejected_missed_deadline,
DROP uniformed_rejected_missed_deadline,
DROP nonmilitary_rejected_missed_deadline,
DROP uocava_rejected_voter_signature_problem,
DROP uniformed_rejected_voter_signature_problem,
DROP nonmilitary_rejected_voter_signature_problem,
DROP uocava_rejected_no_postmark,
DROP uniformed_rejected_no_postmark,
DROP nonmilitary_rejected_no_postmark;



/* Combining the numerous "other" columns in their respective categories by creat one other 
column relevant to each "other" grouping, and filling it with the sum of the "others". For summing
step, null values will be treated as 0. Finally, the numerous "other" columns will be dropped. */


-- Create other_removed column and fill with sum of other1_removed through other4_removed.

ALTER TABLE eavs2018 ADD COLUMN other_removed int;
UPDATE eavs2018
SET other_removed = COALESCE(other1_removed,0) + COALESCE(other2_removed,0) 
+ COALESCE(other3_removed,0)
RETURNING other_removed;


-- Create other_civilian column and fill with sum of other1_civilian through other7_civilian.

ALTER TABLE eavs2018 ADD COLUMN other_civilian int;
UPDATE eavs2018
SET other_civilian = COALESCE(other1_civilian,0) + COALESCE(other2_civilian,0) 
+ COALESCE(other3_civilian,0)
RETURNING other_civilian;


-- Create other_participated column and fill with sum of other1_participated.

ALTER TABLE eavs2018 ADD COLUMN other_participated int;
UPDATE eavs2018
SET other_participated = COALESCE(other1_participated,0)
RETURNING other_participated;

SELECT * FROM eavs2018;

-- Drop various other fields used to create the combined other fields

ALTER TABLE eavs2018
DROP other1_removed,
DROP other2_removed,
DROP other3_removed,
DROP other1_civilian,
DROP other2_civilian,
DROP other3_civilian,
DROP other1_participated;



/* Combining similar civilian_absentee rejection reason columns to reduce by summing similar
columns into new combine column and deleting combined columns. */


-- Create signature_issue_civilian columns and fill with sum of no_voter_signature_civilian, 
-- no_witness_signature_civilian, non_matching_signature_civilian, no_official_signature_civilian

ALTER TABLE eavs2018 ADD COLUMN signature_issue_civilian int;
UPDATE eavs2018
SET signature_issue_civilian = COALESCE(no_voter_signature_civilian,0)
+ COALESCE(no_witness_signature_civilian,0) + COALESCE(non_matching_signature_civilian,0)
+ COALESCE(no_official_signature_civilian,0)
RETURNING signature_issue_civilian;


-- Create envelope_issue_civilian columns and fill with sum of unofficial_envelope_civilian, 
-- envelope_unsealed_civilian, no_address_envelope_civilian, multiple_ballots_envelope_civilian

ALTER TABLE eavs2018 ADD COLUMN envelope_issue_civilian int;
UPDATE eavs2018
SET envelope_issue_civilian = COALESCE(unofficial_envelope_civilian,0)
+ COALESCE(envelope_unsealed_civilian,0) + COALESCE(no_address_envelope_civilian,0)
+ COALESCE(multiple_ballots_envelope_civilian,0)
RETURNING envelope_issue_civilian;


-- Drop columns used to create the combined civilian_absentee rejection reason columns

ALTER TABLE eavs2018
DROP no_voter_signature_civilian,
DROP no_witness_signature_civilian,
DROP non_matching_signature_civilian,
DROP no_official_signature_civilian,
DROP unofficial_envelope_civilian,
DROP envelope_unsealed_civilian,
DROP no_address_envelope_civilian,
DROP multiple_ballots_envelope_civilian;

ALTER TABLE eavs2018
DROP same_day_comment;


SELECT * FROM eavs2018;

SELECT COUNT(*) FROM information_schema.columns
WHERE table_name='eavs2018';



--------------------------------------------------------------------------------
/*				                 Cleaning eavs2020           		  		          */
---------------------------------------------------------------------------------- 

SELECT * FROM eavs2020;

/* Remove all other comment columns. These explanations are not present in large enough
quantities to be aggregated individually. We will simply keep 'other' entries as 'other' 
with no further comment for further analysis. */

ALTER TABLE eavs2020
DROP other1_comment_removed,
DROP other2_comment_removed,
DROP other3_comment_removed,
DROP other1_comment_civilian,
DROP other2_comment_civilian,
DROP other3_comment_civilian,
DROP other1_comment_participated;


/* According to the codebook, 
-99 indicates data not available
-88 indicates data not applicable
-77 indicates no response expected (we will treat as not applicable)
null indicates no response

Since we are primarily assessing voter participation, we will eliminate records with these
3 missing values from registered_eligible_total and participated_total. We will still have
sufficient data to analyze after dropping these records, and not having this data
renders them fairly useless for this analysis. */

DELETE from eavs2020 
WHERE registered_eligible_total IS NULL or registered_eligible_total = '-99'
or registered_eligible_total = '-88' or registered_eligible_total = '-77';

DELETE from eavs2020 
WHERE participated_total IS NULL or participated_total = '-99'
or participated_total = '-88' or participated_total = '-77';

SELECT * FROM eavs2020 LIMIT 20;
SELECT DISTINCT registered_eligible_total FROM eavs2020 ORDER BY registered_eligible_total;
SELECT DISTINCT participated_total FROM eavs2020 ORDER BY participated_total;



/* For the remaining variables in this dataset, we will treat '-88' and '-77' (not applicable) as 0
and '-99' (not available) as null. */


-- f1 - replace all '-88' and '-77' in table with '0'

SELECT f1('eavs2020','-88','0');
SELECT same_day_registration_total FROM eavs2020 WHERE fipscode = '100100000 ';

SELECT f1('eavs2020','-77','0');
SELECT other_uocava FROM eavs2020 WHERE fipscode = '2300902165 ';



-- f2 - replace all '-99' in table with NULL

SELECT f2('eavs2020','-99', NULL);
SELECT uocava_rejected FROM eavs2020 WHERE fipscode = '50275';




/* Casting all numeric columns as int. */

ALTER TABLE eavs2020
    ALTER COLUMN registered_eligible_total TYPE int USING registered_eligible_total::int,
    ALTER COLUMN active_registered_total TYPE int USING active_registered_total::int,
	ALTER COLUMN inactive_registered_total TYPE int USING inactive_registered_total::int,
	ALTER COLUMN same_day_registration_total TYPE int USING same_day_registration_total::int,
	ALTER COLUMN voters_removed_rolls_total TYPE int USING voters_removed_rolls_total::int,
	ALTER COLUMN voters_moved_removed TYPE int USING voters_moved_removed::int,
	ALTER COLUMN voters_died_removed TYPE int USING voters_died_removed::int,
	ALTER COLUMN voter_felony_removed TYPE int USING voter_felony_removed::int,
	ALTER COLUMN longterm_inactive_removed TYPE int USING longterm_inactive_removed::int,
	ALTER COLUMN mentally_incompetent_removed TYPE int USING mentally_incompetent_removed::int,
	ALTER COLUMN voter_request_removed TYPE int USING voter_request_removed::int,
	ALTER COLUMN other1_removed TYPE int USING other1_removed::int,
	ALTER COLUMN other2_removed TYPE int USING other2_removed::int,
	ALTER COLUMN other3_removed TYPE int USING other3_removed::int,
	ALTER COLUMN absentee_uocava_total TYPE int USING absentee_uocava_total::int,
	ALTER COLUMN uocava_rejected TYPE int USING uocava_rejected::int,
	ALTER COLUMN missed_deadline_uocava TYPE int USING missed_deadline_uocava::int,
	ALTER COLUMN voter_signature_problem_uocava TYPE int USING voter_signature_problem_uocava::int,
	ALTER COLUMN no_postmark_uocava TYPE int USING no_postmark_uocava::int,
	ALTER COLUMN other_uocava TYPE int USING other_uocava::int,
	ALTER COLUMN absentee_civilian_total TYPE int USING absentee_civilian_total::int,
	ALTER COLUMN civilian_absentee_counted TYPE int USING civilian_absentee_counted::int,
	ALTER COLUMN civilian_absentee_rejected TYPE int USING civilian_absentee_rejected::int,
	ALTER COLUMN missed_deadline_civilian TYPE int USING missed_deadline_civilian::int,
	ALTER COLUMN no_voter_signature_civilian TYPE int USING no_voter_signature_civilian::int,
	ALTER COLUMN no_witness_signature_civilian TYPE int USING no_witness_signature_civilian::int,
	ALTER COLUMN non_matching_signature_civilian TYPE int USING non_matching_signature_civilian::int,
	ALTER COLUMN no_official_signature_civilian TYPE int USING no_official_signature_civilian::int,
	ALTER COLUMN unofficial_envelope_civilian TYPE int USING unofficial_envelope_civilian::int,
	ALTER COLUMN ballot_missing_civilian TYPE int USING ballot_missing_civilian::int,
	ALTER COLUMN envelope_unsealed_civilian TYPE int USING envelope_unsealed_civilian::int,
	ALTER COLUMN no_address_envelope_civilian TYPE int USING no_address_envelope_civilian::int,
	ALTER COLUMN multiple_ballots_envelope_civilian TYPE int USING multiple_ballots_envelope_civilian::int,
	ALTER COLUMN voter_deceased_civilian TYPE int USING voter_deceased_civilian::int,
	ALTER COLUMN voted_in_person_civilian TYPE int USING voted_in_person_civilian::int,
	ALTER COLUMN improper_id_civilian TYPE int USING improper_id_civilian::int,
	ALTER COLUMN no_ballot_application_civilian TYPE int USING no_ballot_application_civilian::int,
	ALTER COLUMN other1_civilian TYPE int USING other1_civilian::int,
	ALTER COLUMN other2_civilian TYPE int USING other2_civilian::int,
	ALTER COLUMN other3_civilian TYPE int USING other3_civilian::int,
	ALTER COLUMN precincts_total TYPE int USING precincts_total::int,
	ALTER COLUMN polling_places_total TYPE int USING polling_places_total::int,
	ALTER COLUMN poll_workers_total TYPE int USING poll_workers_total::int,
	ALTER COLUMN provisional_ballot_total TYPE int USING provisional_ballot_total::int,
	ALTER COLUMN counted_full_provisional TYPE int USING counted_full_provisional::int,
	ALTER COLUMN counted_partial_provisional TYPE int USING counted_partial_provisional::int,
	ALTER COLUMN rejected_provisional TYPE int USING rejected_provisional::int,
	ALTER COLUMN participated_total TYPE int USING participated_total::int,
	ALTER COLUMN in_person_participated TYPE int USING in_person_participated::int,
	ALTER COLUMN uocava_absentee_participated TYPE int USING uocava_absentee_participated::int,
	ALTER COLUMN civilian_absentee_participated TYPE int USING civilian_absentee_participated::int,
	ALTER COLUMN provisional_participated TYPE int USING provisional_participated::int,
	ALTER COLUMN early_vote_participated TYPE int USING early_vote_participated::int,
	ALTER COLUMN mail_jurisdiction_participated TYPE int USING mail_jurisdiction_participated::int,
	ALTER COLUMN other1_participated TYPE int USING other1_participated::int;




/* Combining the numerous "other" columns in their respective categories by creat one other 
column relevant to each "other" grouping, and filling it with the sum of the "others". For summing
step, null values will be treated as 0. Finally, the numerous "other" columns will be dropped. */


-- Create other_removed column and fill with sum of other1_removed through other4_removed.

ALTER TABLE eavs2020 ADD COLUMN other_removed int;
UPDATE eavs2020
SET other_removed = COALESCE(other1_removed,0) + COALESCE(other2_removed,0) 
+ COALESCE(other3_removed,0)
RETURNING other_removed;


-- Create other_civilian column and fill with sum of other1_civilian through other7_civilian.

ALTER TABLE eavs2020 ADD COLUMN other_civilian int;
UPDATE eavs2020
SET other_civilian = COALESCE(other1_civilian,0) + COALESCE(other2_civilian,0) 
+ COALESCE(other3_civilian,0)
RETURNING other_civilian;


-- Create other_participated column and fill with sum of other1_participated through other2_participated.

ALTER TABLE eavs2020 ADD COLUMN other_participated int;
UPDATE eavs2020
SET other_participated = COALESCE(other1_participated,0)
RETURNING other_participated;


-- Drop various other fields used to create the combined other fields

ALTER TABLE eavs2020
DROP other1_removed,
DROP other2_removed,
DROP other3_removed,
DROP other1_civilian,
DROP other2_civilian,
DROP other3_civilian,
DROP other1_participated;

SELECT * FROM eavs2020



/* Combining similar civilian_absentee rejection reason columns to reduce by summing similar
columns into new combine column and deleting combined columns. */


-- Create signature_issue_civilian columns and fill with sum of no_voter_signature_civilian, 
-- no_witness_signature_civilian, non_matching_signature_civilian, no_official_signature_civilian

ALTER TABLE eavs2020 ADD COLUMN signature_issue_civilian int;
UPDATE eavs2020
SET signature_issue_civilian = COALESCE(no_voter_signature_civilian,0)
+ COALESCE(no_witness_signature_civilian,0) + COALESCE(non_matching_signature_civilian,0)
+ COALESCE(no_official_signature_civilian,0)
RETURNING signature_issue_civilian;


-- Create envelope_issue_civilian columns and fill with sum of unofficial_envelope_civilian, 
-- envelope_unsealed_civilian, no_address_envelope_civilian, multiple_ballots_envelope_civilian

ALTER TABLE eavs2020 ADD COLUMN envelope_issue_civilian int;
UPDATE eavs2020
SET envelope_issue_civilian = COALESCE(unofficial_envelope_civilian,0)
+ COALESCE(envelope_unsealed_civilian,0) + COALESCE(no_address_envelope_civilian,0)
+ COALESCE(multiple_ballots_envelope_civilian,0)
RETURNING envelope_issue_civilian;


-- Drop columns used to create the combined civilian_absentee rejection reason columns

ALTER TABLE eavs2020
DROP no_voter_signature_civilian,
DROP no_witness_signature_civilian,
DROP non_matching_signature_civilian,
DROP no_official_signature_civilian,
DROP unofficial_envelope_civilian,
DROP envelope_unsealed_civilian,
DROP no_address_envelope_civilian,
DROP multiple_ballots_envelope_civilian;

ALTER TABLE eavs2020
DROP same_day_comment;


SELECT * FROM eavs2020;

SELECT COUNT(*) FROM information_schema.columns
WHERE table_name='eavs2020';



--------------------------------------------------------------------------------
/*				                 Cleaning eavs2022           		  		          */
---------------------------------------------------------------------------------- 

SELECT * FROM eavs2022;

/* Remove all other comment columns. These explanations are not present in large enough
quantities to be aggregated individually. We will simply keep 'other' entries as 'other' 
with no further comment for further analysis. */

ALTER TABLE eavs2022
DROP other1_comment_removed,
DROP other2_comment_removed,
DROP other3_comment_removed,
DROP other1_comment_civilian,
DROP other2_comment_civilian,
DROP other3_comment_civilian,
DROP other1_comment_participated;


/* According to the codebook, 
-99 indicates data not available
-88 indicates data not applicable
-77 indicates no response expected (we will treat as not applicable)
null indicates no response

Since we are primarily assessing voter participation, we will eliminate records with these
3 missing values from registered_eligible_total and participated_total. We will still have
sufficient data to analyze after dropping these records, and not having this data
renders them fairly useless for this analysis. */

DELETE from eavs2022 
WHERE registered_eligible_total IS NULL or registered_eligible_total = '-99'
or registered_eligible_total = '-88' or registered_eligible_total = '-77';

DELETE from eavs2022 
WHERE participated_total IS NULL or participated_total = '-99'
or participated_total = '-88' or participated_total = '-77';

SELECT * FROM eavs2022 LIMIT 20;
SELECT DISTINCT registered_eligible_total FROM eavs2022 ORDER BY registered_eligible_total;
SELECT DISTINCT participated_total FROM eavs2022 ORDER BY participated_total;



/* For the remaining variables in this dataset, we will treat '-88' and '-77' (not applicable) as 0
and '-99' (not available) as null. */


-- f1 - replace all '-88' and '-77' in table with '0'

SELECT f1('eavs2022','-88','0');
SELECT same_day_registration_total FROM eavs2022 WHERE fipscode = '100100000  ';

SELECT f1('eavs2022','-77','0');
SELECT other_uocava FROM eavs2022 WHERE fipscode = '104900000  ';



-- f2 - replace all '-99' in table with NULL

SELECT f2('eavs2022','-99', NULL);
SELECT absentee_uocava_total FROM eavs2022 WHERE fipscode = '100100000 ';



SELECT * FROM eavs2022;

/* Casting all numeric columns as int. */

ALTER TABLE eavs2022
    ALTER COLUMN registered_eligible_total TYPE int USING registered_eligible_total::int,
    ALTER COLUMN active_registered_total TYPE int USING active_registered_total::int,
	ALTER COLUMN inactive_registered_total TYPE int USING inactive_registered_total::int,
	ALTER COLUMN same_day_registration_total TYPE int USING same_day_registration_total::int,
	ALTER COLUMN voters_removed_rolls_total TYPE int USING voters_removed_rolls_total::int,
	ALTER COLUMN voters_moved_removed TYPE int USING voters_moved_removed::int,
	ALTER COLUMN voters_died_removed TYPE int USING voters_died_removed::int,
	ALTER COLUMN voter_felony_removed TYPE int USING voter_felony_removed::int,
	ALTER COLUMN longterm_inactive_removed TYPE int USING longterm_inactive_removed::int,
	ALTER COLUMN mentally_incompetent_removed TYPE int USING mentally_incompetent_removed::int,
	ALTER COLUMN voter_request_removed TYPE int USING voter_request_removed::int,
	ALTER COLUMN other1_removed TYPE int USING other1_removed::int,
	ALTER COLUMN other2_removed TYPE int USING other2_removed::int,
	ALTER COLUMN other3_removed TYPE int USING other3_removed::int,
	ALTER COLUMN absentee_uocava_total TYPE int USING absentee_uocava_total::int,
	ALTER COLUMN uocava_rejected TYPE int USING uocava_rejected::int,
	ALTER COLUMN missed_deadline_uocava TYPE int USING missed_deadline_uocava::int,
	ALTER COLUMN voter_signature_problem_uocava TYPE int USING voter_signature_problem_uocava::int,
	ALTER COLUMN no_postmark_uocava TYPE int USING no_postmark_uocava::int,
	ALTER COLUMN other_uocava TYPE int USING other_uocava::int,
	ALTER COLUMN absentee_civilian_total TYPE int USING absentee_civilian_total::int,
	ALTER COLUMN civilian_absentee_counted TYPE int USING civilian_absentee_counted::int,
	ALTER COLUMN civilian_absentee_rejected TYPE int USING civilian_absentee_rejected::int,
	ALTER COLUMN missed_deadline_civilian TYPE int USING missed_deadline_civilian::int,
	ALTER COLUMN no_voter_signature_civilian TYPE int USING no_voter_signature_civilian::int,
	ALTER COLUMN no_witness_signature_civilian TYPE int USING no_witness_signature_civilian::int,
	ALTER COLUMN non_matching_signature_civilian TYPE int USING non_matching_signature_civilian::int,
	ALTER COLUMN unofficial_envelope_civilian TYPE int USING unofficial_envelope_civilian::int,
	ALTER COLUMN ballot_missing_civilian TYPE int USING ballot_missing_civilian::int,
	ALTER COLUMN secrecy_envelope_rejected_civilian TYPE int USING secrecy_envelope_rejected_civilian::int,
	ALTER COLUMN multiple_ballots_envelope_civilian TYPE int USING multiple_ballots_envelope_civilian::int,	
	ALTER COLUMN envelope_unsealed_civilian TYPE int USING envelope_unsealed_civilian::int,
	ALTER COLUMN no_postmark_civilian TYPE int USING no_postmark_civilian::int,	
	ALTER COLUMN no_address_envelope_civilian TYPE int USING no_address_envelope_civilian::int,	
	ALTER COLUMN voter_deceased_civilian TYPE int USING voter_deceased_civilian::int,
	ALTER COLUMN voted_in_person_civilian TYPE int USING voted_in_person_civilian::int,
	ALTER COLUMN improper_id_civilian TYPE int USING improper_id_civilian::int,
	ALTER COLUMN rejected_jurisdiction_eligibility_civilian TYPE int USING rejected_jurisdiction_eligibility_civilian::int,
	ALTER COLUMN no_ballot_application_civilian TYPE int USING no_ballot_application_civilian::int,
	ALTER COLUMN other1_civilian TYPE int USING other1_civilian::int,
	ALTER COLUMN other2_civilian TYPE int USING other2_civilian::int,
	ALTER COLUMN other3_civilian TYPE int USING other3_civilian::int,
	ALTER COLUMN precincts_total TYPE int USING precincts_total::int,
	ALTER COLUMN polling_places_total TYPE int USING polling_places_total::int,
	ALTER COLUMN poll_workers_total TYPE int USING poll_workers_total::int,
	ALTER COLUMN provisional_ballot_total TYPE int USING provisional_ballot_total::int,
	ALTER COLUMN counted_full_provisional TYPE int USING counted_full_provisional::int,
	ALTER COLUMN counted_partial_provisional TYPE int USING counted_partial_provisional::int,
	ALTER COLUMN rejected_provisional TYPE int USING rejected_provisional::int,
	ALTER COLUMN participated_total TYPE int USING participated_total::int,
	ALTER COLUMN in_person_participated TYPE int USING in_person_participated::int,
	ALTER COLUMN uocava_absentee_participated TYPE int USING uocava_absentee_participated::int,
	ALTER COLUMN civilian_absentee_participated TYPE int USING civilian_absentee_participated::int,
	ALTER COLUMN provisional_participated TYPE int USING provisional_participated::int,
	ALTER COLUMN early_vote_participated TYPE int USING early_vote_participated::int,
	ALTER COLUMN mail_jurisdiction_participated TYPE int USING mail_jurisdiction_participated::int,
	ALTER COLUMN other1_participated TYPE int USING other1_participated::int;




/* Combining the numerous "other" columns in their respective categories by creat one other 
column relevant to each "other" grouping, and filling it with the sum of the "others". For summing
step, null values will be treated as 0. Finally, the numerous "other" columns will be dropped. */


-- Create other_removed column and fill with sum of other1_removed through other4_removed.

ALTER TABLE eavs2022 ADD COLUMN other_removed int;
UPDATE eavs2022
SET other_removed = COALESCE(other1_removed,0) + COALESCE(other2_removed,0) 
+ COALESCE(other3_removed,0)
RETURNING other_removed;


-- Create other_civilian column and fill with sum of other1_civilian through other7_civilian.

ALTER TABLE eavs2022 ADD COLUMN other_civilian int;
UPDATE eavs2022
SET other_civilian = COALESCE(other1_civilian,0) + COALESCE(other2_civilian,0) 
+ COALESCE(other3_civilian,0)
RETURNING other_civilian;


-- Create other_participated column and fill with sum of other1_participated through other2_participated.

ALTER TABLE eavs2022 ADD COLUMN other_participated int;
UPDATE eavs2022
SET other_participated = COALESCE(other1_participated,0)
RETURNING other_participated;


-- Drop various other fields used to create the combined other fields

ALTER TABLE eavs2022
DROP other1_removed,
DROP other2_removed,
DROP other3_removed,
DROP other1_civilian,
DROP other2_civilian,
DROP other3_civilian,
DROP other1_participated;

SELECT * FROM eavs2022



/* Combining similar civilian_absentee rejection reason columns to reduce by summing similar
columns into new combine column and deleting combined columns. */


-- Add new to this year category of rejected_jurisdiction_eligibility_civilian to other_civilian

UPDATE eavs2022
SET other_civilian = COALESCE(other_civilian,0) + COALESCE(rejected_jurisdiction_eligibility_civilian,0)
RETURNING other_civilian;



-- Create signature_issue_civilian columns and fill with sum of no_voter_signature_civilian, 
-- no_witness_signature_civilian, non_matching_signature_civilian

ALTER TABLE eavs2022 ADD COLUMN signature_issue_civilian int;
UPDATE eavs2022
SET signature_issue_civilian = COALESCE(no_voter_signature_civilian,0)
+ COALESCE(no_witness_signature_civilian,0) + COALESCE(non_matching_signature_civilian,0)
RETURNING signature_issue_civilian;


-- Create envelope_issue_civilian columns and fill with sum of unofficial_envelope_civilian, 
-- envelope_unsealed_civilian, no_address_envelope_civilian, multiple_ballots_envelope_civilian

ALTER TABLE eavs2022 ADD COLUMN envelope_issue_civilian int;
UPDATE eavs2022
SET envelope_issue_civilian = COALESCE(unofficial_envelope_civilian,0)
+ COALESCE(secrecy_envelope_rejected_civilian,0) + COALESCE(multiple_ballots_envelope_civilian,0)
+ COALESCE(envelope_unsealed_civilian,0) + COALESCE(no_postmark_civilian,0)
+ COALESCE(no_address_envelope_civilian,0)
RETURNING envelope_issue_civilian;


-- Drop columns used to create the combined civilian_absentee rejection reason columns

ALTER TABLE eavs2022
DROP rejected_jurisdiction_eligibility_civilian,
DROP no_voter_signature_civilian,
DROP no_witness_signature_civilian,
DROP non_matching_signature_civilian,
DROP unofficial_envelope_civilian,
DROP secrecy_envelope_rejected_civilian,
DROP multiple_ballots_envelope_civilian,
DROP envelope_unsealed_civilian,
DROP no_postmark_civilian,
DROP no_address_envelope_civilian;

ALTER TABLE eavs2022
DROP same_day_comment;


SELECT COUNT(*) FROM information_schema.columns
WHERE table_name='eavs2022';

SELECT * FROM eavs2022;