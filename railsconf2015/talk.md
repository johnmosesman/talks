# RailsConf 2015
## Code Structures

1. Level 1: No structure
  A. Why: Just learning how to type the words
  B. Smell: everything is in controller action
  C. Conclusion: That's ok. Most important thing is learning the framework/language—don't prematurely optimize.
2. Level 2: "Fat Models Skinny Controllers"
  A. Why: "Controllers should only be 3 lines."
  B.
    i. Smell: Massive files
      1. Case: 3k line User.rb
    ii. Smell: Anything that uses the model name ends up in the file
      1. Case: Counting how many times a user has used a hashtag on Instagram.
         -> It has "user" in the name?
  C. Conclusion: Slightly better. The controller is cleaner, but we've really just taken the mess in the center of the room and shoved it in the closet. The house isn't actually any better organized. "Hiding the mess."
3. Level 3: SRP
  A. Why: Maintainability and readability
  B. Smell:
    i. "User model is 3k lines of code and handles who knows what."
    ii. Defining how two non-associated objects work together
      Ex: TODO
    iii. SRP-violation: looking at our example again
  C. Conclusion: Objects perform one function so the code is more maintainable and more readable.
4. Level 4: ???
  A. I'd like to hear from you. What's the next level from here?
  B. If I'm totally wrong, let me know
