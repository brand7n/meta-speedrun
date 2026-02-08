# Limit parallel compile to avoid OOM on 16GB systems
# WebKitGTK cc1plus processes use 1-1.3GB each
PARALLEL_MAKE = "-j 4"
