ARG ODOO_VERSION
FROM odoo:${ODOO_VERSION}
USER root
RUN mkdir /mnt/enterprise-addons && chown -R odoo /mnt/enterprise-addons
USER odoo