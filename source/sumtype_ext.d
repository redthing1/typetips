module typetips.sumtype_ext;

public import std.sumtype;

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
        return fruit.match!(
            (Apple a) => a.yummy,
            (Pear p) => p.was_picked_yesterday
        );
    }
}

T1 as(T2, T1)(T2 t2) {
    return cast(T1) t2;
}

@("sumtype-as") unittest {
    struct SoyMilk {
        float gallons;
    }

    struct Bread {
        int slices;
    }

    alias StoreThing = SumType!(SoyMilk, Bread);

    auto s1 = SoyMilk(1.5);
    auto s2 = Bread(2);

    auto bread2 = s2.as!(Bread);
}
