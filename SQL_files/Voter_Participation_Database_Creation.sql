/*
    Nicole Blosser
	
    Voter Participation Project using the biannual Election Administration and Voting Survey Report
	conducted by the United States Election Assistance Commission.
	
	EAVS survey years used: 2014, 2016, 2018, 2020, 2022
	
	Voter ID Law Data prepared for this project as well using information from the National Conference
	of State Legislatures and the Brennan Center for Justice
	
	This SQL database will be used to prepare a Tableau Dashboard


*/

--------------------------------------------------------------------------------
/*				                 2014 EAVS Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE eavs2014 (
	
	fipscode char(10),
	state char(2),
	jurisdiction varchar(100),
	registered_eligible_total text,
	active_inactive text,
	active_registered_total text,
	inactive_registered_total text,
	same_day_registration_total text,
	same_day_comment text,
	voters_removed_rolls_total text,
	voters_moved_removed text,
	voters_died_removed text,
	voter_felony_removed text,
	longterm_inactive_removed text,
	mentally_incompetent_removed text,
	voter_request_removed text,
	other1_removed text,
	other1_comment_removed text,
	other2_removed text,
	other2_comment_removed text,
	other3_removed text,
	other3_comment_removed text,
	other4_removed text, 
	other4_comment_removed text,
	absentee_uocava_total text,
	uocava_rejected text,
	missed_deadline_uocava text,
	voter_signature_problem_uocava text,
	no_postmark_uocava text,
	other_uocava text,
	absentee_civilian_total text,
	civilian_absentee_counted text,
	civilian_absentee_rejected text,
	missed_deadline_civilian text,
	no_voter_signature_civilian text,
	no_witness_signature_civilian text,
	non_matching_signature_civilian text,
	no_official_signature_civilian text,
	unofficial_envelope_civilian text,
	ballot_missing_civilian text,
	envelope_unsealed_civilian text,
	no_address_envelope_civilian text,
	multiple_ballots_envelope_civilian text,
	voter_deceased_civilian text,
	voted_in_person_civilian text,
	improper_id_civilian text,
	no_ballot_application_civilian text,
	other1_civilian text,
	other1_comment_civilian text,
	other2_civilian text,
	other2_comment_civilian text,
	other3_civilian text,
	other3_comment_civilian text,
	other4_civilian text,
	other4_comment_civilian text,
	other5_civilian text,
	other5_comment_civilian text,
	other6_civilian text,
	other6_comment_civilian text,
	other7_Civilian text,
	other7_comment_civilian text,
	precincts_total text,
	polling_places_total text,
	poll_workers_total text,
	provisional_ballot_total text,
	counted_full_provisional text,
	counted_partial_provisional text,
	rejected_provisional text,
	participated_total text,
	in_person_participated text,
	uocava_absentee_participated text,
	civilian_absentee_participated text,
	provisional_participated text,
	early_vote_participated text,
	mail_jurisdiction_participated text,
	other1_participated text,
	other1_comment_participated text,
	other2_participated text,
	other2_comment_participated text
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY eavs2014
FROM 'C:\Users\Public\2014_EAVS.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM eavs2014 LIMIT 10;

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
/*				                 2016 EAVS Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE eavs2016 (
	
	fipscode char(10),
	state char(2),
	jurisdiction varchar(100),
	registered_eligible_total text,
	active_inactive text,
	active_registered_total text,
	inactive_registered_total text,
	same_day_registration_total text,
	same_day_comment text,
	voters_removed_rolls_total text,
	voters_moved_removed text,
	voters_died_removed text,
	voter_felony_removed text,
	longterm_inactive_removed text,
	mentally_incompetent_removed text,
	voter_request_removed text,
	other1_comment_removed text,
	other1_removed text,
	other2_comment_removed text,
	other2_removed text,
	other3_comment_removed text,
	other3_removed text,
	other4_comment_removed text,
	other4_removed text, 
	absentee_uocava_total text,
	uocava_rejected text,
	missed_deadline_uocava text,
	voter_signature_problem_uocava text,
	no_postmark_uocava text,
	other_uocava text,
	absentee_civilian_total text,
	civilian_absentee_counted text,
	civilian_absentee_rejected text,
	missed_deadline_civilian text,
	no_voter_signature_civilian text,
	no_witness_signature_civilian text,
	non_matching_signature_civilian text,
	no_official_signature_civilian text,
	unofficial_envelope_civilian text,
	ballot_missing_civilian text,
	envelope_unsealed_civilian text,
	no_address_envelope_civilian text,
	multiple_ballots_envelope_civilian text,
	voter_deceased_civilian text,
	voted_in_person_civilian text,
	improper_id_civilian text,
	no_ballot_application_civilian text,
	other1_comment_civilian text,
	other1_civilian text,
	other2_comment_civilian text,
	other2_civilian text,
	other3_comment_civilian text,
	other3_civilian text,
	other4_comment_civilian text,
	other4_civilian text,
	other5_comment_civilian text,
	other5_civilian text,
	other6_comment_civilian text,
	other6_civilian text,
	other7_comment_civilian text,
	other7_civilian text,
	other8_comment_civilian text,
	other8_civilian text,
	precincts_total text,
	polling_places_total text,
	poll_workers_total text,
	provisional_ballot_total text,
	counted_full_provisional text,
	counted_partial_provisional text,
	rejected_provisional text,
	participated_total text,
	in_person_participated text,
	uocava_absentee_participated text,
	civilian_absentee_participated text,
	provisional_participated text,
	early_vote_participated text,
	mail_jurisdiction_participated text,
	other1_comment_participated text,
	other1_participated text,
	other2_comment_participated text,
	other2_participated text,
	other3_comment_participated text,
	other3_participated text
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY eavs2016
FROM 'C:\Users\Public\2016_EAVS.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM eavs2016 LIMIT 10;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
/*				                 2018 EAVS Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE eavs2018 (
	
	fipscode char(10),
	jurisdiction varchar(100),
	state char(2),
	registered_eligible_total text,
	active_registered_total text,
	inactive_registered_total text,
	same_day_registration_total text,
	same_day_comment text,
	voters_removed_rolls_total text,
	voters_moved_removed text,
	voters_died_removed text,
	voter_felony_removed text,
	longterm_inactive_removed text,
	mentally_incompetent_removed text,
	voter_request_removed text,
	other1_comment_removed text,
	other1_removed text,
	other2_comment_removed text,
	other2_removed text,
	other3_comment_removed text,
	other3_removed text,
	absentee_uocava_total text,
	uocava_rejected text,
	uocava_rejected_missed_deadline text,
	uniformed_rejected_missed_deadline text,
	nonmilitary_rejected_missed_deadline text,
	uocava_rejected_voter_signature_problem text,
	uniformed_rejected_voter_signature_problem text,
	nonmilitary_rejected_voter_signature_problem text,
	uocava_rejected_no_postmark text,
	uniformed_rejected_no_postmark text,
	nonmilitary_rejected_no_postmark text,
	other_uocava text,
	absentee_civilian_total text,
	civilian_absentee_counted text,
	civilian_absentee_rejected text,
	missed_deadline_civilian text,
	no_voter_signature_civilian text,
	no_witness_signature_civilian text,
	non_matching_signature_civilian text,
	no_official_signature_civilian text,
	unofficial_envelope_civilian text,
	ballot_missing_civilian text,
	envelope_unsealed_civilian text,
	no_address_envelope_civilian text,
	multiple_ballots_envelope_civilian text,
	voter_deceased_civilian text,
	voted_in_person_civilian text,
	improper_id_civilian text,
	no_ballot_application_civilian text,
	other1_comment_civilian text,
	other1_civilian text,
	other2_comment_civilian text,
	other2_civilian text,
	other3_comment_civilian text,
	other3_civilian text,
	precincts_total text,
	polling_places_total text,
	poll_workers_total text,
	provisional_ballot_total text,
	counted_full_provisional text,
	counted_partial_provisional text,
	rejected_provisional text,
	participated_total text,
	in_person_participated text,
	uocava_absentee_participated text,
	civilian_absentee_participated text,
	provisional_participated text,
	early_vote_participated text,
	mail_jurisdiction_participated text,
	other1_comment_participated text,
	other1_participated text
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY eavs2018
FROM 'C:\Users\Public\2018_EAVS.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM eavs2018 LIMIT 10;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
/*				                 2020 EAVS Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE eavs2020 (
	
	fipscode char(10),
	jurisdiction varchar(100),
	state char(2),
	registered_eligible_total text,
	active_registered_total text,
	inactive_registered_total text,
	same_day_registration_total text,
	same_day_comment text,
	voters_removed_rolls_total text,
	voters_moved_removed text,
	voters_died_removed text,
	voter_felony_removed text,
	longterm_inactive_removed text,
	mentally_incompetent_removed text,
	voter_request_removed text,
	other1_comment_removed text,
	other1_removed text,
	other2_comment_removed text,
	other2_removed text,
	other3_comment_removed text,
	other3_removed text,
	absentee_uocava_total text,
	uocava_rejected text,
	missed_deadline_uocava text,
	voter_signature_problem_uocava text,
	no_postmark_uocava text,
	other_uocava text,
	absentee_civilian_total text,
	civilian_absentee_counted text,
	civilian_absentee_rejected text,
	missed_deadline_civilian text,
	no_voter_signature_civilian text,
	no_witness_signature_civilian text,
	non_matching_signature_civilian text,
	no_official_signature_civilian text,
	unofficial_envelope_civilian text,
	ballot_missing_civilian text,
	envelope_unsealed_civilian text,
	no_address_envelope_civilian text,
	multiple_ballots_envelope_civilian text,
	voter_deceased_civilian text,
	voted_in_person_civilian text,
	improper_id_civilian text,
	no_ballot_application_civilian text,
	other1_comment_civilian text,
	other1_civilian text,
	other2_comment_civilian text,
	other2_civilian text,
	other3_comment_civilian text,
	other3_civilian text,
	precincts_total text,
	polling_places_total text,
	poll_workers_total text,
	provisional_ballot_total text,
	counted_full_provisional text,
	counted_partial_provisional text,
	rejected_provisional text,
	participated_total text,
	in_person_participated text,
	uocava_absentee_participated text,
	civilian_absentee_participated text,
	provisional_participated text,
	early_vote_participated text,
	mail_jurisdiction_participated text,
	other1_comment_participated text,
	other1_participated text
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY eavs2020
FROM 'C:\Users\Public\2020_EAVS.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM eavs2020 LIMIT 10;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
/*				                 2022 EAVS Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE eavs2022 (
	
	fipscode char(10),
	jurisdiction varchar(100),
	state char(2),
	registered_eligible_total text,
	active_registered_total text,
	inactive_registered_total text,
	same_day_registration_total text,
	same_day_comment text,
	voters_removed_rolls_total text,
	voters_moved_removed text,
	voters_died_removed text,
	voter_felony_removed text,
	longterm_inactive_removed text,
	mentally_incompetent_removed text,
	voter_request_removed text,
	other1_comment_removed text,
	other1_removed text,
	other2_comment_removed text,
	other2_removed text,
	other3_comment_removed text,
	other3_removed text,
	absentee_uocava_total text,
	uocava_rejected text,
	missed_deadline_uocava text,
	voter_signature_problem_uocava text,
	no_postmark_uocava text,
	other_uocava text,
	absentee_civilian_total text,
	civilian_absentee_counted text,
	civilian_absentee_rejected text,
	missed_deadline_civilian text,
	no_voter_signature_civilian text,
	no_witness_signature_civilian text,
	non_matching_signature_civilian text,
	unofficial_envelope_civilian text,
	ballot_missing_civilian text,
	secrecy_envelope_rejected_civilian text,
	multiple_ballots_envelope_civilian text,
	envelope_unsealed_civilian text,
	no_postmark_civilian text,
	no_address_envelope_civilian text,
	voter_deceased_civilian text,
	voted_in_person_civilian text,
	improper_id_civilian text,
	rejected_jurisdiction_eligibility_civilian text,
	no_ballot_application_civilian text,
	other1_comment_civilian text,
	other1_civilian text,
	other2_comment_civilian text,
	other2_civilian text,
	other3_comment_civilian text,
	other3_civilian text,
	precincts_total text,
	polling_places_total text,
	poll_workers_total text,
	provisional_ballot_total text,
	counted_full_provisional text,
	counted_partial_provisional text,
	rejected_provisional text,
	participated_total text,
	in_person_participated text,
	uocava_absentee_participated text,
	civilian_absentee_participated text,
	provisional_participated text,
	early_vote_participated text,
	mail_jurisdiction_participated text,
	other1_comment_participated text,
	other1_participated text
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY eavs2022
FROM 'C:\Users\Public\2022_EAVS.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM eavs2022 LIMIT 10;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
/*				                 Voter ID Law Table Creation		  		          */
--------------------------------------------------------------------------------


CREATE TABLE id_law (
	
	state char(2),
	year_enacted int,
	strictness boolean
);
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
/*				                 Import Data           		  		          */
--------------------------------------------------------------------------------

COPY id_law
FROM 'C:\Users\Public\Voter_ID_Laws.csv'
WITH (FORMAT CSV,HEADER);


SELECT * FROM id_law LIMIT 10;
--------------------------------------------------------------------------------


/*				              
	Create a backups of imported tables.

*/
--------------------------------------------------------------------------------

CREATE TABLE eavs2014_backup AS SELECT * FROM eavs2014;
CREATE TABLE eavs2016_backup AS SELECT * FROM eavs2016;
CREATE TABLE eavs2018_backup AS SELECT * FROM eavs2018;
CREATE TABLE eavs2020_backup AS SELECT * FROM eavs2020;
CREATE TABLE eavs2022_backup AS SELECT * FROM eavs2022;

DROP TABLE eavs2014;
CREATE TABLE eavs2014 AS SELECT * FROM eavs2014_backup;
SELECT * FROM eavs2014;

