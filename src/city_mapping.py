''' Canonical city-name mapping across the GREIX source files
(City_metrics_public, City_Metrics_rents_sales, ETW_EFH_TOM).

Different files spell the same city differently. This module
maps every known raw spelling to one standardized name, so joins
across files work correctly. '''

GREIX_NATIONAL = "GREIX_NATIONAL"

CITY_NAME_MAP = {'FFM' : 'Frankfurt am Main',
                 'REK' : 'Rhein-Erft-Kreis',
                 'Mettmann' : 'Kreis Mettmann',
                 'Mettmann_Kreis' : 'Kreis Mettmann',
                 'Greix' : GREIX_NATIONAL,
                 'GREIX' : GREIX_NATIONAL , }

def canonical_city(raw_name : str) -> str:
    if raw_name is None:
        return raw_name
    return CITY_NAME_MAP.get(raw_name, raw_name)