# README

Hello everyone! 🥸

This silly project is our playground for learning and experimenting with service objects and controller refactorings. Rails controllers and to some extent graphql resolvers (especially for mutations) are very prominent to attract more and more code if you are not paying attention. On the example of `BookingsController#create` you can follow through the journey of how it transformed from

https://github.com/igor-ladkin/bookery/blob/49399622f0d249827e202a6b29d792ee5634ba32/app/controllers/bookings_controller.rb#L8-L16

into

https://github.com/igor-ladkin/bookery/blob/9aef5f0e876e1f21df1e7d1285e322b6690cc224/app/controllers/bookings_controller.rb#L9-L66

On top of that, lots of logic are hidden behind special-case validations on model as well as some significant chunk of action callbacks.

It only took 12 simple business requirement adjustments and bug reports to get from the old to the new. It happens to us every day.
I hope that this small experiment will give you more confidence to refactor your code.

## How to setup

```sh
➜ ruby -v
ruby 3.1.1p18

git clone git@github.com:igor-ladkin/bookery.git
cd bookery
bundle

rails db:setup
rspec
rails server
```

## Tips

- 👨‍🎨 There is no real user management in this project. To mimic different users' sessions, you can open any page and pass `u` query parameter. For example http://localhost:3000?u=sasho.
- 💿 Don't be afraid to use `rails db:seed` to reset your database.
- 🤪 Have fun!

## How to get the most from the exercise

1. Write code. One thing is to read somebody else's code and another one is to try solving this problem yourself. This difference is significant and is caused by the type of work we do. When we are reviewing someone else's code, we are not looking for the solution, but the essence of the problem. When you are solving the problem, you are not only looking for the solution but you constantly have to make a choice. How to name things, where to put them, is it the efficient way? Too many things at the same time.

2. If you want to see how we landed in the situation we are in, you can see these 12 business requirements represented in respective branches `br-1..br-12`. You can try to make changes in the code yourself to make the tests pass. Let's compare if you are happy with the result.

3. If you only want to try refactoring the whole mess, then `refactoring-start` branch is the starting point for you.
