public class DataUtils {
    // Hacky but quick way to get a string date in a compatible DateTime format.
    // To avoid EXTERNAL_OBJECT_EXCEPTION in SOQL when requesting a date field
    // '2020-06-19T01:45:17Z' -> '2020-06-19 01:45:17'
    public static String transformDate(Object rawDate){
        if (rawDate == null) {
            return '';
        }
        String castedDate=(String)rawDate;
        return castedDate.replace('T', ' ').replace('Z', '');
    }
}
