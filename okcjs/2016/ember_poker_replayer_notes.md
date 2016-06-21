# Building a Poker Hand Replayer in Ember.js

Note: This is a condensed version of the slides 
minus all of the non-Ember relevant stuff.

## In the past we might do something like this:

```
var player, pot;

function performAction(theBet) {
  // Do the calculations
  player.updateBet(theBet);
  player.updateStack(-theBet);

  pot.updateAmount(theBet);
  pot.recalculateOdds();

  // Update the UI
  this.playerBetLabel = player.bet;
  this.playerStackLabel = player.stack;

  this.potLabel = pot.amount;
  this.oddsLabel = pot.odds;
}
```

## But, computed properties make this easier!

# Computed properties

## A computed property is:

### "A function that dynamically updates its return value when it observes changes to the properties it depends on."
### - Ember docs paraphrase

The classic example: 

```
// person.js
Person = Ember.Object.extend({
  firstName: null,
  lastName: null,

  fullName: Ember.computed('firstName', 'lastName', function() {
    return `${this.get('firstName')} ${this.get('lastName')}`;
  })
});

// profile.hbs
{{#each players as |player|}}
  <div>
    {{player.fullName}}
  </div>
{{/each}}
```


# The poker example

```
// template.hbs
{{#each players as |player|}}
  <div>
    <p>{{player.stack}}</p>

    {{#if player.hasBet}}
      <div>{{player.currentBet}}</div>
    {{/if}}

    ...
{{/each}}

// player.js
Player = Ember.Model.extend({
  bets: [],

  hasBet: Ember.computed('bets', function() {
    return this.get('bets').length > 0;
  }),

  currentBet: Ember.computed.sum('bets')
});
```

### What about the total amount in the pot?

```
// template.hbs
<div>
  <p>Total pot: {{pot.total}}</p>
</div>

// player.js
Player = Ember.Model.extend({
  bets: [],

  hasBet: ...
  currentBet: Ember.computed.sum('bets')
});

// pot_(_not_weed_).js
Pot = Ember.Model.extend({
  players: [],

  currentBets: Ember.computed.mapBy('players', 'currentBet'),

  total: Ember.computed.sum('currentBets'),

  odds: Ember.computed('total', function() {
    // Calculate odds
  })
})
```

All of this is set into motion by:

```
> player.get('bets').push(5);
```

# Thanks!
## John Mosesman
### @johnmosesman

Resources:

  - [Computed properties docs](https://guides.emberjs.com/v2.3.0/object-model/computed-properties/)

  - [TodoMVC in Ember](http://todomvc.com/examples/emberjs/)

  - [Mike North's Compose All The Things talk](http://www.slideshare.net/mikelnorth/compose-all-the-things)
