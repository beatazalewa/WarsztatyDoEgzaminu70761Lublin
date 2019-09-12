/*The following code demonstrates using both functions:*/

SELECT
SWITCHOFFSET('20170212 14:00:00.0000000 -05:00',
'-08:00') AS [SWITCHOFFSET],
TODATETIMEOFFSET('20170212 14:00:00.0000000', '-08:00')
AS [TODATETIMEOFFSET];
/*This code generates the following output: 

SWITCHOFFSET                         TODATETIMEOFFSET
----------------------------------   -----------------------
2017-02-12 11:00:00.0000000 -08:00   2017-02- 12 14:00:00.0000000 -08:00
*/
/*
What’s tricky about both functions is that many time zones support a
daylight savings concept where twice a year you move the clock by an hour.
So when you capture the date and time value, you need to make sure that you
also capture the right offset depending on whether it’s currently daylight
savings or not. For instance, in the time zone Pacific Standard Time the offset
from UTC is ‘-07:00’ when it’s daylight savings time and ‘-08:00’ when it
isn’t.
*/