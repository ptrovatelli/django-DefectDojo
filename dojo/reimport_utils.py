from django.conf import settings
from dojo.models import Finding

import logging

logger = logging.getLogger(__name__)
deduplicationLogger = logging.getLogger("dojo.specific-loggers.deduplication")

"""
Common code for reimporting from APIV2 or from the GUI
"""


def get_deduplication_algorithm_from_conf(scan_type):
    # Default algorithm
    deduplication_algorithm = 'legacy'
    # Check for an override for this scan_type in the deduplication configuration
    if hasattr(settings, 'DEDUPLICATION_ALGORITHM_PER_PARSER') and scan_type in settings.DEDUPLICATION_ALGORITHM_PER_PARSER:
        deduplication_algorithm = settings.DEDUPLICATION_ALGORITHM_PER_PARSER[scan_type]
    return deduplication_algorithm


def match_new_finding_to_existing_finding(item, test, deduplication_algorithm, scan_type):
    if deduplication_algorithm == 'hash_code':
        return Finding.objects.filter(
            test=test,
            hash_code=item.hash_code).exclude(
                        hash_code=None).all()
    elif deduplication_algorithm == 'unique_id_from_tool' or deduplication_algorithm == 'unique_id_from_tool_or_hash_code':
        # processing 'unique_id_from_tool_or_hash_code' as 'unique_id_from_tool' because when using 'unique_id_from_tool_or_hash_code'
        # we usually want to use 'hash_code' for cross-parser matching, 
        # while it makes more sense to use the 'unique_id_from_tool' for same-parser matching
        return Finding.objects.filter(
            test=test,
            unique_id_from_tool=item.unique_id_from_tool).exclude(
                        unique_id_from_tool=None).all()
    elif deduplication_algorithm == 'legacy':
        # This is the legacy reimport behavior. Although it's pretty flawed and doesn't match the legacy algorithm for deduplication,
        # this is left as is for simplicity. 
        # Re-writing the legacy deduplication here would be complicated and counter-productive. 
        # If you have use cases going through this section, you're advised to create a deduplication configuration for your parser
        logger.debug("Legacy reimport. In case of issue, you're advised to create a deduplication configuration in order not to go through this section")
        if scan_type == 'Arachni Scan':
            return Finding.objects.filter(
                title=item.title,
                test=test,
                severity=item.severity,
                numerical_severity=Finding.get_numerical_severity(item.severity),
                description=item.description).all()
        else:
            return Finding.objects.filter(
                title=item.title,
                test=test,
                severity=item.severity,
                numerical_severity=Finding.get_numerical_severity(item.severity)).all()
    else:
        logger.error("Internal error: unexpected deduplication_algorithm: '%s' ", deduplication_algorithm)
        return None
