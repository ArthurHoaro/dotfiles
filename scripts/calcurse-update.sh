#!/bin/bash

rm ~/.local/share/calcurse/apts

# Appartement
wget -qO- https://calendar.google.com/calendar/ical/e3fn0i5tdhljtf5tpduv1bco08%40group.calendar.google.com/private-afd9c48644d93ec25be5acd5f64b3131/basic.ics | calcurse -i -

# Google général
wget -qO- https://calendar.google.com/calendar/ical/arthur.hoareau%40gmail.com/private-974e3afc6fe4d65760f617562b8f0657/basic.ics | calcurse -i -

