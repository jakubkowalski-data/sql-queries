-- Opis:
-- Zapytanie wybiera sesje, w których wystąpiło więcej niż 2 eventy.
-- Następnie zlicza liczbę takich sesji z podziałem na kraj (country).
-- Wynik zawiera kolumny:
-- country - kraj użytkownika
-- session_cnt - liczba sesji spełniających warunek (>2 eventy)

-- Logika:
-- 1. Podzapytanie wybiera sesje z więcej niż 2 eventami
-- 2. JOIN łączy je z tabelą session_params (żeby pobrać kraj)
-- 3. GROUP BY agreguje dane po kraju




SELECT
  session_params.country,
  COUNT(DISTINCT event_counts.ga_session_id) AS session_cnt
FROM
  `data-analytics-mate.DA.session_params` AS session_params
INNER JOIN (
  SELECT
    ga_session_id
  FROM
    `data-analytics-mate.DA.event_params`
  GROUP BY
    ga_session_id
  HAVING
    COUNT(event_name) > 2 ) AS event_counts
ON
  session_params.ga_session_id = event_counts.ga_session_id
GROUP BY
  session_params.country
ORDER BY
  session_cnt DESC;
