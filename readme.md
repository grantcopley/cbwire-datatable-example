# CBWIRE DataTable Example

Here you will find a fully functional DataTable implemented almost entirely in CFML using CBWIRE. The DataTable has the following features that were built from the ground up:

* Single CBWIRE Component ( wires/Datatable.cfm - provides all functionality )
* List NES games
* Set the number of games displayed per page
* Pagination
* Reset button to start over
* Click anywhere on the row to select a game
* Select all games listed
* Search field to match any column
* Sort columns by ascending or descending
* Select games by checkbox
* Shift+Click to select multiple games
* Save favorite games w/ confirmation

## Screenshot
<img width="800" alt="CleanShot 2023-08-29 at 00 38 12@2x" src="https://github.com/grantcopley/cbwire-datatable-example/assets/1197835/045181ca-0c87-4980-9879-d4e8b56aa452">

## Core Files

These files you'll want to open and tinker with to learn how to build your own CBWIRE DataTable.

* wires/Datatable.cfm
* layouts/Main.cfm

## Requirements

* CommandBox 5.8+

## Getting Started

* Clone this repo `git clone git@github.com:grantcopley/cbwire-datatable-example.git`
* Use CommandBox to install dependencies `box install`
* Start your CFML server `box server start --open`

After the server completes startup, your browser will open automatically and the DataTable should be visible.
