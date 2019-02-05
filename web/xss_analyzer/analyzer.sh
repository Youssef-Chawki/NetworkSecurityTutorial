# to launch everything
tail -f /var/log/apache2/modsec.log | python -u parser.py | python -u scalp.py -f modified_filter.xml -z | python -u producer.py
