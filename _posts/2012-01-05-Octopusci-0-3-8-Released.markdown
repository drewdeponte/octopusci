---
layout: post
title: Octopusci v0.3.8 Released
tags: [code]
---

Woot woot. We just released the v0.3.8 of Octopusci. This release includes two pretty imporantant
changes.

 * octopusci-tentacles now runs as a non-root user (specified in config general section under key tentacles_user)
 * jobs are now run with the HOME, SHELL, and USER env vars set to the info associated with the specified user.
 * a OCTOPUSCI environment variable is set for all commands run via jobs to allow for scripts to determine if they are being run by Octopusci

This was just a quick patch fix release we wanted to get out to help our wonderful sponsor [RealPractice](http://www.realpractice.com/).
Beyond that it was pretty lame that the octopusci-tentacles daemon required some wrapper script hacking to get it to run as non-root
so we decided we better just add it and save people the effort.