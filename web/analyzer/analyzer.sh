# to launch everything
#tail -f /var/log/apache2/modsec.log | python -u /analyzer/parser.py | python -u /analyzer/scalp.py -f /analyzer/modified_filter.xml -z | python -u /analyzer/producer.py
tail -f /apache/logs/access.log | python -u /analyzer/producer.py

