# LTSP tools
LTSP server installation workflow in a nutshell.

This project is intended for a clean Debian GNU/Linux stable (actual codename jessie).

## Quick start
Assuming:
* Your default gateway at `eth0` (your Internet access)
* A network switch/hub attached to `eth1` (LTSP thin clients LAN)
* Network bootable computers attached to the switch/hub, attached to `eth1`

Then:

    sudo apt-get install bzr
    bzr branch lp:ltsp-tools
    cd ./ltsp-tools

    # Run the install.
    sudo ./install.sh

Now try to boot your clients. It should work! In future, run simply `./start.sh` instead of re-installing.

## LTSP documentation
* http://wiki.ltsp.org/wiki/LTSPedia
* https://wiki.debian.org/LTSP

## Project history
* 2013 — [Valerio Bozzolan](https://boz.reyboz.it) [discovered](http://www.ltsp.org/stories/viewstory/?story_id=470&secret=f42d2c) the LTSP project spreading it with a small paper *[LIM, LTSP, E-Register. Sustainable technology for teaching](https://boz.reyboz.it/content/tesina-2013-14-itis-avogadro-valerio-bozzolan.pdf)*. Uploaded an [experience demostration](https://www.youtube.com/watch?v=ycG6GqKnkSA).
* 2016 november — The [WEEE Open](http://weeeopen.eu) team, founded by Marco Signoretto at the Politecnico of Turin, is mature. This repository started.
* 2016 november 22  — The WEEE Open team is involved in the *Sustainability week*. This repository was used to build a demostration LTSP server, showing a thin client usable without an hard-disk and with very low hardware resources.

This project also contributed a little into the Debian wiki documentation after november 2016:
* https://wiki.debian.org/LTSP/LDMTheme — Created
* https://wiki.debian.org/LTSP/Epoptes — Created
* https://wiki.debian.org/it/LTSP/Epoptes — Created

## Hacking
We actually work using `bzr`. Please contribute using `bzr`.

GIT PULL REQUESTS WILL BE IGNORED/OVERWRITED!

## License
This program is Free as in Freedom software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
