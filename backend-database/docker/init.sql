create EXTENSION if not exists "uuid-ossp";

-- สร้าง Enum สำหรับ status 
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_status') THEN
        CREATE TYPE product_status AS ENUM ('active', 'inactive');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_type') THEN
        CREATE TYPE product_type AS ENUM ('arttoy', 'figure', 'accessory');
    END IF;
END$$;

create table sellers (
    seller_id uuid primary key default uuid_generate_v4(),
    name varchar(255) not null unique,
    contact_info varchar(255),
    created_at date default current_date,
    updated_at date default current_date
);

create table categories (
    category_id serial primary key,
    name varchar(255) not null unique,
    description text
);

create table products (
    product_id uuid primary key default uuid_generate_v4(),
    name varchar(255) not null,
    description text,
    brand varchar(255),
    model_number varchar(100),
    price numeric(10,2) not null check (price >= 0),
    status product_status not null,
    seller_id uuid not null,
    category_id integer not null,
    product_type product_type not null,
    created_at date default current_date,
    updated_at date default current_date,
    foreign key (seller_id) references sellers(seller_id) on delete cascade,
    foreign key (category_id) references categories(category_id) on delete cascade
);

create table product_images (
    image_id uuid primary key default uuid_generate_v4(),
    product_id uuid not null,
    image_url text not null,
    alt_text varchar(255),
    is_primary boolean default false,
    sort_order integer default 0,
    uploaded_at date default current_date,
    created_at date default current_date,
    updated_at date default current_date,
    foreign key (product_id) references products(product_id) on delete cascade
);

create table inventory (
    product_id uuid primary key,
    quantity integer not null check (quantity >= 0),
    updated_at date default current_date,
    foreign key (product_id) references products(product_id) on delete cascade
);

create or replace function update_updated_at_column()
returns trigger AS $$
begin
    NEW.updated_at = current_date;
    return NEW;
end;
$$ language 'plpgsql';

create trigger update_products_updated_at before update on products
for each row execute procedure update_updated_at_column();

create trigger update_products_updated_at before update on sellers
for each row execute procedure update_updated_at_column();

create trigger update_products_updated_at before update on product_images
for each row execute procedure update_updated_at_column();

create trigger update_products_updated_at before update on inventory
for each row execute procedure update_updated_at_column();

insert into sellers (name, contact_info) values
('Atongshopp 玩具', 'https://www.facebook.com/atongshopp/?locale=zh_CN'),
('Art Toys', 'https://www.facebook.com/Art.toys94/?locale=th_TH'),
('Gachabox', 'https://www.facebook.com/gachabox/?locale=th_TH'),
('POP MART', 'https://www.popmart.com/th'),
('PIECE Of JOY', 'https://www.facebook.com/pieceofjoyyy/?locale=th_TH');

insert into categories (name, description) values
('อาร์ททอย', 'ของเล่นที่ถูกออกแบบและผลิตเป็นงานศิลปะ'),
('ฟิกเกอร์', 'หุ่นจำลองขนาดเล็กที่สร้างเพื่อแสดงถึงตัวละคร'),
('อุปกรณ์เสริม', 'สิ่งของเพิ่มเติมที่ใช้ประกอบหรือตกแต่ง');

insert into products (name, description, brand, model_number, price, status, seller_id, category_id, product_type) 
values
    ('Duckyo’s Leisure Life',
    'กล่องสุ่ม Duckyo’s Leisure Life 12 รูปแบบ ไม่ซ้ำลายหากซื้อเป็นยกเซ็ต (1 เซ็ต = 12 กล่อง)',
    'Duckyo’s',
    'DY-AT-2024',
    320,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Lord May King series',
    'กล่องสุ่ม Lord May King 6 รูปแบบ พร้อมลุ้นได้ตัวsecret ไม่ซ้ำลายหากซื้อเป็นยกเซ็ต (1 เซ็ต = 6 กล่อง)',
    'FUFUTIETIE',
    'FFTT-AT-2024',
    450,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('KUROMI Chess',
    'กล่องสุ่ม KUROMI Chess 9 รูปแบบ(8ตัวปกติ และ 1ตัวsecret) ไม่ซ้ำลายหากซื้อเป็นยกเซ็ต (1 เซ็ต = 8 กล่อง)',
    'Sanrio',
    'SAN-FG-2024',
    400,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('ANGEL IN CLOUDS Vinyl Face Doll',
    'กล่อง ANGEL IN CLOUDS Vinyl Face Doll (ขนาด : 33*25*58cm)',
    'THE MONSTERS',
    'TM-AT-2024',
    6790,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Superstar Dance Moves',
    'กล่อง Superstar Dance Moves (ขนาด : 15*23cm)',
    'LABUBU',
    'LBB-FG-2024',
    1050,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('Teletubbies Tinky Winky Trendy',
    'กล่องTeletubbies Tinky Winky Trendy 4 รูปแบบ (ขนาด : 5*10.5cm)',
    'Art Toys',
    'AT-FG-2024',
    550,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('Doraemon: Concert series',
    'กล่องสุ่ม Doraemon: Concert series 9 รูปแบบ(8ตัวปกติ และ 1ตัวsecret) ไม่ซ้ำลายหากซื้อเป็นยกเซ็ต (1 เซ็ต = 8 กล่อง)',
    '52toys',
    '52T-FG-2024',
    2900,
    'active',
    (select seller_id from sellers where name = 'Art Toys' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ), ---- Atongshopp 玩具
    ('SKULLPANDA Tell Me What You Want Series Figures',
    'กล่องสุ่ม ขนาด6-13cm. ผลิตจากวัสดุ PVC / ABS / Polyester / Nylon / Magnet',
    'SKULLPANDA',
    'SPD-AT-2024',
    400,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Hirono×Le Petit Prince Series Blind Box Figures',
    'กล่องสุ่ม ขนาด 7-17 ซม. ผลิตจากวัสดุ Resin/PVC',
    'Hirono',
    'HRN-AT-2024',
    460,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Sank-Good Night Series-Stellar Trail',
    'กล่องสุ่ม ขนาด7.4 * 7 * 14.5 ซม. ผลิตจากวัสดุ Resin',
    'Sank',
    'S-FG-2024',
    4250,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('MOLLY carb - Lover Series Figures',
    'กล่องสุ่มขนาด7-11 เซนติเมตร ทำจากวัสดุPVC',
    'MOLLY',
    'ML-AT-2024',
    400,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('FORERUNNER Limited Blister card',
    'กล่องสุ่มขนาด 8.5-9 เซนติเมตร ทำจากวัสดุคุณภาพสูง PVC มีความทนทาน',
    'FORERUNNER',
    'FRN-AT-2024',
    2400,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('CRYBABY Crying Again Series-Card Holder Blind Box',
    'กล่องสุ่มขนาดประมาณ 14.5-17 ซม. ผลิตจากวัสดุ Polyester/PVC/PP/Zinc Alloy',
    'CRYBABY',
    'CBB-FG-2024',
    450,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('BABY ZORAA - I’m the BOSS',
    'กล่องสุ่มขนาดประมาณ 9-12 ซม. ผลิตจากวัสดุ ABS/PVC',
    'BABY ZORAA',
    'BBZR-AT-2024',
    400,
    'active',
    (select seller_id from sellers where name = 'Atongshopp 玩具' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ), ------- PIECE Of JOY
    ('จาน Rico ซีรี่ย์ 2',
    'แบบสุ่ม จาน Rico ซีรี่ย์ 2',
    'RICO',
    'RC-ACC-2024',
    299,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อุปกรณ์เสริม' limit 1),
    'accessory'
    ),
    ('RICO Sweet Time',
    'กล่องสุ่ม RICO Sweet Time / ยกกล่อง',
    'RICO',
    'RC-AT-2024',
    2390,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('RICO Happy Picnic Together',
    'กล่องสุ่ม RICO Happy Picnic Together / ยกกล่อง',
    'RICO',
    'RC-AT-2024',
    3490,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Baby Three V1',
    'กล่องสุ่ม Baby Three V1 รุ่นอัพเกรดตา / ยกกล่อง',
    'Baby Three',
    'BBT-AT-2024',
    2250,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Baby Three Ocean',
    'กล่องสุ่ม Baby Three Ocean',
    'Baby Three',
    'BBT-AT-2024',
    399,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Baby Three V.3',
    'กล่องสุ่ม Baby Three V.3 / ยกกล่อง',
    'Baby Three',
    'BBT-AT-2024',
    3200,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Maltese Hipper',
    'altese Hipper เกาะมือถือ',
    'Maltese',
    'MT-ACC-2024',
    259,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อุปกรณ์เสริม' limit 1),
    'accessory'
    ),
    ('ที่เปิดขวด babythree',
    'แบบสุ่ม ที่เปิดขวด Babythree',
    'Baby Three',
    'BBT-ACC-2024',
    199,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อุปกรณ์เสริม' limit 1),
    'accessory'
    ),
    ('Shinwoo Happy birthday',
    'โมเดล Shinwoo Happy birthday v.แกะการ์ด',
    'F.UN',
    'F-AT-2024',
    17000,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('MEGA MOLLY SPACE V.3',
    'กล่องสุ่ม MEGA MOLLY SPACE V.3 / ยกกล่อง',
    'MOLLY',
    'MT-AT-2024',
    5000,
    'active',
    (select seller_id from sellers where name = 'PIECE Of JOY' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ), ----POP MART
    ('CRYBABY × Powerpuff Girls Series Figures',
    'กล่องสุ่ม ขนาด 6-9 ซม. ผลิตจาก PVC/ABS แข็งแรง ทนทาน ในเซ็ตประกอบด้วยฟิกเกอร์ 12 ชิ้น (ไม่มีซ้ำเมื่อซื้อทั้งเซ็ต) รวมความน่ารักสดใสของ Blossom, Bubbles, และ Buttercup ไว้ในหนึ่งเดียว เหมาะสำหรับนักสะสมและแฟนการ์ตูนตัวจริง!',
    'CRYBABY',
    'CBB-FG-2024',
    380,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('CRYBABY Crying Again Series-Card Holder Blind Box',
    'ฟิกเกอร์ขนาด 14.5-17 ซม. ผลิตจากวัสดุคุณภาพสูง (Polyester, PVC, PP, และ Zinc Alloy) ทั้งเซ็ตมี 6 ชิ้นแบบสุ่ม โดยหากซื้อทั้งเซ็ต รับประกันไม่มีชิ้นซ้ำ ดีไซน์เก๋และใช้งานได้จริงในรูปแบบที่ใส่การ์ด เหมาะสำหรับนักสะสมและผู้ที่ชื่นชอบไอเท็มสุดพิเศษ!',
    'CRYBABY',
    'CBB-AT-2024',
    380,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('CRYBABY Crying Again Series-Plush Badge Blind Box',
    'กล่องสุ่ม ขนาด 8x4x8 ซม. ผลิตจากวัสดุคุณภาพสูง (Zinc Alloy, Copper, Iron) พร้อมปลอกและไส้ในจากโพลีเอสเตอร์ 100% ในเซ็ตประกอบด้วยกล่องสุ่ม 12 ชิ้น และรับประกันไม่มีชิ้นซ้ำเมื่อซื้อทั้งเซ็ต ดีไซน์น่ารักและนุ่มนิ่ม เหมาะสำหรับนักสะสมและแฟนตัวยงที่ชอบของสะสมสุดพิเศษ!',
    'CRYBABY',
    'CBB-AT-2024',
    270,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box',
    'กล่องสุ่ม ขนาด 21x7.6x0.8 ซม. ผลิตจากวัสดุ PU และกระจก ในเซ็ตประกอบด้วยกล่องสุ่ม 6 ชิ้น รับประกันไม่มีชิ้นซ้ำเมื่อซื้อทั้งเซ็ต ดีไซน์สวยงาม มีเอกลักษณ์แบบไทย ๆ เหมาะสำหรับสะสมหรือพกพาเป็นเครื่องประดับเก๋ ๆ ที่ใช้งานได้จริง!',
    'CRYBABY',
    'CBB-FG-2024',
    320,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('SKULLPANDA Tell Me What You Want Series Figures',
    'กล่องสุ่ม ฟิกเกอร์ขนาด 6-13 ซม. ผลิตจาก PVC, ABS, Polyester, Nylon และแม่เหล็ก ในเซ็ตประกอบด้วยกล่องสุ่ม 9 ชิ้น โดยหากซื้อทั้งเซ็ต รับประกันไม่มีชิ้นซ้ำ และยังมีโอกาสลุ้นรับฟิกเกอร์ลับสุดพิเศษ เหมาะสำหรับนักสะสมที่ต้องการเพิ่มความตื่นเต้นให้กับคอลเลกชันของตน!',
    'SKULLPANDA',
    'SPD-FG-2024',
    380,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('Disney Winnie the Pooh Gift Giving Series Figures',
    'กล่องสุ่ม  ขนาดความสูงรวมประมาณ 10 ซม. ผลิตจากวัสดุ PVC และ ABS ในเซ็ตประกอบด้วยกล่องสุ่ม 9 ชิ้น โดยหากซื้อทั้งเซ็ต รับประกันไม่มีชิ้นซ้ำ พร้อมโอกาสลุ้นรับฟิกเกอร์ลับสุดน่ารัก เหมาะสำหรับแฟน ๆ ดิสนีย์และนักสะสมที่ต้องการเติมเต็มความสดใสของ Winnie the Pooh ในคอลเลกชันของตน!',
    'Disney',
    'DN-FG-2024',
    380,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('BAZBON Label Plan Series 1/8 Action Figure',
    'กล่องสุ่ม ขนาด 6.5x6.5x22 ซม. ผลิตจาก PVC, ABS, PA, Cotton, Terylene, Spandex, PU Leather และ Hardware ในเซ็ตมี 4 ชิ้น (ไม่มีซ้ำเมื่อซื้อทั้งเซ็ต) พร้อมโอกาสลุ้นฟิกเกอร์ลับ เหมาะสำหรับนักสะสมฟิกเกอร์แอ็กชัน!',
    'BAZBON',
    'BB-FG-2024',
    1550,
    'active',
    (select seller_id from sellers where name = 'POP MART' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ), -----Gachabox
    ('Mr. Bone Mini 002 Time Travel Series Blind Box',
    'มี 9 แบบ + 1 Secret + 1 Super Secret วัสดุ PVC/ABS',
    'Mytoy',
    'MT-AT-2024',
    439,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Mr Bone Junior First Day Series Blind Box',
    'มี 9 แบบ + 2 Secret + 1 Super Secret วัสดุ PVC/ABS',
    'Mytoy',
    'MT-AT-2024',
    369,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Hirono Mime Series Cable Iphone Blind Box',
    'มี 12 แบบ + 1 แบบพิเศษ วัสดุ Silicone/TPE/PVC Lightning/Type-C',
    'Hirono',
    'HRN-ACC-2024',
    299,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='อุปกรณ์เสริม' limit 1),
    'accessory'
    ),
    ('POLAR - HELLO POLAR Season 1 Series Figures',
    'มีแบบปกติ 12 แบบ + แบบลับ 1 แบบ',
    'POLAR',
    'PL-FG-2024',
    380,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='ฟิกเกอร์' limit 1),
    'figure'
    ),
    ('Neon Genesis Evangelion x WASA EVA 206 Series Blind Box',
    'มี 6 แบบ + 1 แบบพิเศษ',
    'Lamtoys',
    'LT-AT-2024',
    550,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    ),
    ('Bearbrick series 44 100% by Medicom Toy Blind Box',
    '-',
    'Medicom Toy',
    'MCT-AT-2024',
    220,
    'active',
    (select seller_id from sellers where name = 'Gachabox' limit 1),
    (select category_id from categories where name ='อาร์ททอย' limit 1),
    'arttoy'
    );

insert into product_images (product_id, image_url, alt_text, is_primary, sort_order) 
values
    ((select product_id from products where name = 'Duckyo’s Leisure Life' limit 1),
    '/assets/images/arttoys/Duckyo’s Leisure Life-1.jpg',
    'Duckyo’s Leisure Life รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Duckyo’s Leisure Life' limit 1),
    '/assets/images/arttoys/Duckyo’s Leisure Life-2.jpg',
    'Duckyo’s Leisure Life รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Lord May King series' limit 1),
    '/assets/images/arttoys/Lord May King series-1.jpg',
    'Lord May King series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    '/assets/images/arttoys/KUROMI Chess-1.png',
    'KUROMI Chess รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    '/assets/images/arttoys/KUROMI Chess-2.png',
    'KUROMI Chess รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    '/assets/images/arttoys/ANGEL IN CLOUDS Vinyl Face Doll-1.jpg',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    '/assets/images/arttoys/ANGEL IN CLOUDS Vinyl Face Doll-2.jpg',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Superstar Dance Moves' limit 1),
    '/assets/images/arttoys/Superstar Dance Moves-1.jpg',
    'Superstar Dance Moves รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Teletubbies Tinky Winky Trendy' limit 1),
    '/assets/images/arttoys/Teletubbies Tinky Winky Trendy-1.jpg',
    'Teletubbies Tinky Winky Trendy รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    '/assets/images/arttoys/Doraemon Concert series-1.png',
    'Doraemon: Concert series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    '/assets/images/arttoys/Doraemon Concert series-2.png',
    'Doraemon: Concert series รูปที่ 2',
    false,
    2
    ), ---- Atongshopp 玩具
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    '/assets/images/atongshopp/SKULLPANDA Tell Me What You Want Series Figures-1.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    '/assets/images/atongshopp/SKULLPANDA Tell Me What You Want Series Figures-2.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    '/assets/images/atongshopp/SKULLPANDA Tell Me What You Want Series Figures-3.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    '/assets/images/atongshopp/Hirono×Le Petit Prince Series Blind Box Figures-1.jpg',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    '/assets/images/atongshopp/Hirono×Le Petit Prince Series Blind Box Figures-2.jpg',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    '/assets/images/atongshopp/Hirono×Le Petit Prince Series Blind Box Figures-3.jpg',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    '/assets/images/atongshopp/Sank-Good Night Series-Stellar Trail-1.jpg',
    'Sank-Good Night Series-Stellar Trail รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    '/assets/images/atongshopp/Sank-Good Night Series-Stellar Trail-2.jpg',
    'Sank-Good Night Series-Stellar Trail รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    '/assets/images/atongshopp/Sank-Good Night Series-Stellar Trail-3.jpg',
    'Sank-Good Night Series-Stellar Trail รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    '/assets/images/atongshopp/MOLLY carb - Lover Series Figures-1.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    '/assets/images/atongshopp/MOLLY carb - Lover Series Figures-2.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    '/assets/images/atongshopp/MOLLY carb - Lover Series Figures-3.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    '/assets/images/atongshopp/FORERUNNER Limited Blister card-1.jpg',
    'FORERUNNER Limited Blister card รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    '/assets/images/atongshopp/FORERUNNER Limited Blister card-2.jpg',
    'FORERUNNER Limited Blister card รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    '/assets/images/atongshopp/CRYBABY Crying Again Series-Card Holder Blind Box-1.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    '/assets/images/atongshopp/CRYBABY Crying Again Series-Card Holder Blind Box-2.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    '/assets/images/atongshopp/CRYBABY Crying Again Series-Card Holder Blind Box-3.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    '/assets/images/atongshopp/BABY ZORAA - I’m the BOSS-1.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    '/assets/images/atongshopp/BABY ZORAA - I’m the BOSS-2.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    '/assets/images/atongshopp/BABY ZORAA - I’m the BOSS-3.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 3',
    false,
    3
    ), ---- PIECE Of JOY
    ((select product_id from products where name = 'จาน Rico ซีรี่ย์ 2' limit 1),
    '/assets/images/pieceofjoy/จาน Rico ซีรี่ย์ 2-1.jpg',
    'จาน Rico ซีรี่ย์ 2 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    '/assets/images/pieceofjoy/RICO Sweet Time-1.jpg',
    'RICO Sweet Time รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    '/assets/images/pieceofjoy/RICO Sweet Time-2.jpg',
    'RICO Sweet Time รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    '/assets/images/pieceofjoy/RICO Sweet Time-3.jpg',
    'RICO Sweet Time รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    '/assets/images/pieceofjoy/RICO Sweet Time-4.jpg',
    'RICO Sweet Time รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    '/assets/images/pieceofjoy/RICO Happy Picnic Together-1.jpg',
    'RICO Happy Picnic Together รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    '/assets/images/pieceofjoy/RICO Happy Picnic Together-2.jpg',
    'RICO Happy Picnic Together รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    '/assets/images/pieceofjoy/RICO Happy Picnic Together-3.jpg',
    'RICO Happy Picnic Together รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Baby Three V1' limit 1),
    '/assets/images/pieceofjoy/Baby Three V1-1.jpg',
    'Baby Three V1 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three V1' limit 1),
    '/assets/images/pieceofjoy/Baby Three V1-2.jpg',
    'Baby Three V1 รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    '/assets/images/pieceofjoy/Baby Three Ocean-1.jpg',
    'Baby Three Ocean รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    '/assets/images/pieceofjoy/Baby Three Ocean-2.jpg',
    'Baby Three Ocean รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    '/assets/images/pieceofjoy/Baby Three Ocean-3.jpg',
    'Baby Three Ocean รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    '/assets/images/pieceofjoy/Baby Three V.3-1.jpg',
    'Baby Three V.3 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    '/assets/images/pieceofjoy/Baby Three V.3-2.jpg',
    'Baby Three V.3 รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    '/assets/images/pieceofjoy/Baby Three V.3-3.jpg',
    'Baby Three V.3 รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Maltese Hipper' limit 1),
    '/assets/images/pieceofjoy/Maltese Hipper-1.jpg',
    'Maltese Hipper รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ที่เปิดขวด babythree' limit 1),
    '/assets/images/pieceofjoy/ที่เปิดขวด babythree-1.jpg',
    'ที่เปิดขวด babythree รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ที่เปิดขวด babythree' limit 1),
    '/assets/images/pieceofjoy/ที่เปิดขวด babythree-2.jpg',
    'ที่เปิดขวด babythree รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    '/assets/images/pieceofjoy/Shinwoo Happy birthday-1.jpg',
    'Shinwoo Happy birthday รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    '/assets/images/pieceofjoy/Shinwoo Happy birthday-2.jpg',
    'Shinwoo Happy birthday รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    '/assets/images/pieceofjoy/Shinwoo Happy birthday-3.jpg',
    'Shinwoo Happy birthday รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'MEGA MOLLY SPACE V.3' limit 1),
    '/assets/images/pieceofjoy/MEGA MOLLY SPACE V.3-1.jpg',
    'MEGA MOLLY SPACE V.3 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'MEGA MOLLY SPACE V.3' limit 1),
    '/assets/images/pieceofjoy/MEGA MOLLY SPACE V.3-2.jpg',
    'MEGA MOLLY SPACE V.3 รูปที่ 2',
    false,
    2
    ), --- POP MART
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    '/assets/images/popmart/CRYBABY × Powerpuff Girls Series Figures-1.jpg',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    '/assets/images/popmart/CRYBABY × Powerpuff Girls Series Figures-2.jpg',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    '/assets/images/popmart/CRYBABY × Powerpuff Girls Series Figures-3.jpg',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Card Holder Blind Box-1.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Card Holder Blind Box-2.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Card Holder Blind Box-3.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Plush Badge Blind Box-1.jpg',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Plush Badge Blind Box-2.jpg',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY Crying Again Series-Plush Badge Blind Box-3.jpg',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box-1.jpg',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box-2.jpg',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box-3.jpg',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    '/assets/images/popmart/CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box-4.jpg',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    '/assets/images/popmart/SKULLPANDA Tell Me What You Want Series Figures-1.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    '/assets/images/popmart/SKULLPANDA Tell Me What You Want Series Figures-2.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    '/assets/images/popmart/SKULLPANDA Tell Me What You Want Series Figures-3.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    '/assets/images/popmart/SKULLPANDA Tell Me What You Want Series Figures-4.jpg',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    '/assets/images/popmart/Disney Winnie the Pooh Gift Giving Series Figures-1.jpg',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    '/assets/images/popmart/Disney Winnie the Pooh Gift Giving Series Figures-2.jpg',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    '/assets/images/popmart/Disney Winnie the Pooh Gift Giving Series Figures-3.jpg',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    '/assets/images/popmart/BAZBON Label Plan Series 1-8 Action Figure-1.jpg',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    '/assets/images/popmart/BAZBON Label Plan Series 1-8 Action Figure-2.jpg',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    '/assets/images/popmart/BAZBON Label Plan Series 1-8 Action Figure-3.jpg',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 3',
    false,
    3
    ), -----Gachabox
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr. Bone Mini 002 Time Travel Series Blind Box-1.jpg',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr. Bone Mini 002 Time Travel Series Blind Box-2.jpg',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr. Bone Mini 002 Time Travel Series Blind Box-3.jpg',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr. Bone Mini 002 Time Travel Series Blind Box-4.jpg',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr Bone Junior First Day Series Blind Box-1.jpg',
    'Mr Bone Junior First Day Series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr Bone Junior First Day Series Blind Box-2.jpg',
    'Mr Bone Junior First Day Series รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    '/assets/images/gachabox/Mr Bone Junior First Day Series Blind Box-3.jpg',
    'Mr Bone Junior First Day Series รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Hirono Mime Series Cable Iphone Blind Box' limit 1),
    '/assets/images/gachabox/Hirono Mime Series Cable Iphone Blind Box-1.jpg',
    'Hirono Mime Series-Cable รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Hirono Mime Series Cable Iphone Blind Box' limit 1),
    '/assets/images/gachabox/Hirono Mime Series Cable Iphone Blind Box-2.jpg',
    'Hirono Mime Series-Cable รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    '/assets/images/gachabox/POLAR - HELLO POLAR Season 1 Series Figures-1.jpg',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    '/assets/images/gachabox/POLAR - HELLO POLAR Season 1 Series Figures-2.jpg',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    '/assets/images/gachabox/POLAR - HELLO POLAR Season 1 Series Figures-3.jpg',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    '/assets/images/gachabox/Neon Genesis Evangelion x WASA EVA 206 Series Blind Box-1.jpg',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    '/assets/images/gachabox/Neon Genesis Evangelion x WASA EVA 206 Series Blind Box-2.jpg',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    '/assets/images/gachabox/Neon Genesis Evangelion x WASA EVA 206 Series Blind Box-3.jpg',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Bearbrick series 44 100% by Medicom Toy Blind Box' limit 1),
    '/assets/images/gachabox/Bearbrick series 44 100 by Medicom Toy Blind Box-1.jpg',
    'Bearbrick series 44 100% by Medicom Toy Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Bearbrick series 44 100% by Medicom Toy Blind Box' limit 1),
    '/assets/images/gachabox/Bearbrick series 44 100 by Medicom Toy Blind Box-2.jpg',
    'Bearbrick series 44 100% by Medicom Toy Blind Box รูปที่ 2',
    false,
    2
    );

insert into inventory (product_id, quantity)
values
    ((select product_id from products where name = 'Duckyo’s Leisure Life' limit 1), 100),
    ((select product_id from products where name = 'Lord May King series' limit 1), 100),
    ((select product_id from products where name = 'KUROMI Chess' limit 1), 100),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1), 100),
    ((select product_id from products where name = 'Superstar Dance Moves' limit 1), 100),
    ((select product_id from products where name = 'Teletubbies Tinky Winky Trendy' limit 1), 100),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1), 100),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1), 100),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1), 100),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1), 100),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1), 100),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1), 100),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1), 100),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1), 100),
    ((select product_id from products where name = 'จาน Rico ซีรี่ย์ 2' limit 1), 100),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1), 100),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1), 100),
    ((select product_id from products where name = 'Baby Three V1' limit 1), 100),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1), 100),
    ((select product_id from products where name = 'Baby Three V.3' limit 1), 100),
    ((select product_id from products where name = 'Maltese Hipper' limit 1), 100),
    ((select product_id from products where name = 'ที่เปิดขวด babythree' limit 1), 100),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1), 100),
    ((select product_id from products where name = 'MEGA MOLLY SPACE V.3' limit 1), 100),
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1), 100),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1), 100),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1), 100),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1), 100),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1), 100),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1), 100),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1), 100),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1), 100),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1), 100),
    ((select product_id from products where name = 'Hirono Mime Series Cable Iphone Blind Box' limit 1), 100),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1), 100),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1), 100),
    ((select product_id from products where name = 'Bearbrick series 44 100% by Medicom Toy Blind Box' limit 1), 100);

-- สร้าง ENUM สำหรับ user_status และ user_role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('customer', 'seller', 'admin');
    END IF;
END$$;

-- สร้างตาราง users
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    profile_picture_url VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    status user_status NOT NULL DEFAULT 'active',
    role user_role NOT NULL DEFAULT 'customer',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- สร้างตาราง user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    id_token TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- สร้างตาราง user_login_history
CREATE TABLE IF NOT EXISTS user_login_history (
    login_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    login_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- สร้างตาราง api_keys
CREATE TABLE IF NOT EXISTS api_keys (
    key_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_key VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_sessions_updated_at
BEFORE UPDATE ON user_sessions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_api_keys_updated_at
BEFORE UPDATE ON api_keys
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- สร้าง Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_login_history_user_id ON user_login_history(user_id);
CREATE INDEX idx_api_keys_api_key ON api_keys(api_key);