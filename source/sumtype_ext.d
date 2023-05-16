module typetips.sumtype_ext;

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

    bool get_is_yummy(Fruit fruit) {
        return fruit.match_sumtype!(
            (Apple a) => a.yummy,
            (Pear p) => p.was_picked_yesterday
        );
    }
}

Optional!TOneType as(TSumType, TOneType)(TSumType thing) {
    return thing.match_sumtype!(
        (TOneType t) => some(t),
        _ => no!TOneType
    );
}

@("sumtype-as") unittest {
    struct SoyMilk {
        float gallons;
    }

    struct Bread {
        int slices;
    }

    alias StoreThing = SumType!(SoyMilk, Bread);

    auto bread2 = Bread(2);

    StoreThing s1 = SoyMilk(1.5);
    StoreThing s2 = bread2;
    
    auto maybe_bread2_back = as!(StoreThing, Bread)(s2);
    assert(maybe_bread2_back.any, "maybe_bread2_back should be some");
    auto bread2_back = maybe_bread2_back.get;
    assert(bread2 == bread2_back, "bread2 should equal bread2_back");
}
