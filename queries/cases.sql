SELECT
  count(ccase.id) as total,
  contact.id as contact_id,
  contact.sort_name as contact_sort_name,
  ccase.id,
  (SELECT case_type.title FROM civicrm_case_type case_type WHERE case_type.id = ccase.case_type_id) as case_type,
  ccase.status_id,
  ccase.subject,
  ccase.start_date,
  ccase.end_date,
  YEAR(ccase.start_date) as year
FROM civicrm_contact contact
  INNER JOIN
  civicrm_case_contact case_contact
  ON contact.id = case_contact.contact_id
  INNER JOIN
  civicrm_case ccase
  ON case_contact.case_id = ccase.id
WHERE ccase.is_deleted = 0
GROUP BY ccase.id, contact.id
ORDER BY ccase.start_date DESC;