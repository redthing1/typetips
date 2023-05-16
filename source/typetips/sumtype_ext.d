module typetips.sumtype_ext;

import std.exception : enforce, assertThrown;
public import std.sumtype : SumType;
public import std.sumtype : match_sumtype = match;

import typetips.optional_ext;

@("sumtype-basic") unittest {
    struct Apple {
        string variety;
        bool yummy;
    }

    struct Pear {
        int size;
        bool was_picked_yesterday;
    }

    alias Fruit = SumType!(Apple, Pear);

    auto f1 = Apple("Granny Smith");
    auto f2 = Pear(3);
}

template SumTypeExt(TSumType) {
    alias Sum = TSumType;
    Optional!TOneType as(TOneType)(TSumType thing) {
        return thing.match_sumtype!(
            (TOneType t) => some(t),
            _ => no!TOneType
        );
    }

    bool holds(TOneType)(TSumType thing) {
        return thing.match_sumtype!(
            (TOneType t) => true,
            _ => false
        );
    }

    TOneType unwrap(TOneType)(TSumType thing) {
        enforce(holds!TOneType(thing), "unwrap should only be called on a SumType that holds the type");
        return thing.match_sumtype!(
            (TOneType t) => t,
            _ => assert(0),
        );
    }

    Sum wrap(TOneType)(TOneType opt) {
        return cast(TSumType) opt;
    }

    Optional!Sum maybe_wrap(TOneType)(Optional!TOneType opt) {
        if (opt.any) {
            return some(wrap(opt.get));
        } else {
            return no!Sum;
        }
    }
}

@("sumtype-ext") unittest {
    struct SoyMilk {
        float gallons;
    }

    struct Bread {
        int slices;
    }

    alias StoreThing = SumTypeExt!(SumType!(SoyMilk, Bread));

    auto bread2 = Bread(2);

    StoreThing.Sum s1 = SoyMilk(1.5);
    StoreThing.Sum s2 = bread2;

    auto maybe_bread2_back = StoreThing.as!Bread(s2);
    assert(maybe_bread2_back.any, "maybe_bread2_back should be some");
    auto bread2_back = maybe_bread2_back.get;
    assert(bread2 == bread2_back, "bread2 should equal bread2_back");

    auto bread2_taken = StoreThing.unwrap!Bread(s2);
    assert(bread2 == bread2_taken, "bread2 should equal bread2_taken");

    auto probably_not_milk = StoreThing.as!SoyMilk(s2);
    assert(!probably_not_milk.any, "probably_not_milk should be no");

    auto s1_holds_milk = StoreThing.holds!SoyMilk(s1);
    assert(s1_holds_milk, "s1 should hold milk");

    auto s2_doesnt_hold_milk = StoreThing.holds!SoyMilk(s2);
    assert(!s2_doesnt_hold_milk, "s2 shouldn't hold milk");

    StoreThing.Sum get_todays_item(int day) {
        if (day % 2 == 0) {
            return StoreThing.wrap(SoyMilk(1.5));
        } else {
            return StoreThing.wrap(Bread(2));
        }
    }

    Optional!(StoreThing.Sum) get_cheap_milk(int day) {
        Optional!SoyMilk maybe_milk;
        if (day == 0 || day == 1) {
            maybe_milk = some(SoyMilk(1.5));
        } else {
            maybe_milk = no!SoyMilk;
        }
        return StoreThing.maybe_wrap(maybe_milk);
    }

    int guess_price(StoreThing.Sum item) {
        return item.match_sumtype!(
            (SoyMilk milk) => cast(int)(milk.gallons * 2),
            (Bread bread) => bread.slices / 8,
        );
    }

    auto soymilk_2gal = SoyMilk(2);
    assert(guess_price(StoreThing.wrap(soymilk_2gal)) == 4, "soymilk_2gal should be $4");

    auto todays_item_day0 = get_todays_item(0);
    auto todays_item_day1 = get_todays_item(1);
    assert(StoreThing.holds!SoyMilk(todays_item_day0), "todays_item_day0 should hold milk");

    auto maybe_cheap_milk_day1 = get_cheap_milk(1);
    assert(maybe_cheap_milk_day1.any, "cheap_milk_day1 should be some");

    auto maybe_cheap_milk_day2 = get_cheap_milk(2);
    assert(!maybe_cheap_milk_day2.any, "cheap_milk_day2 should be no");
}
