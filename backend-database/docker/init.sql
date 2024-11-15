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
    'https://prod-thailand-res.popmart.com/default/20240924_164239_014944____1_____1200x1200.jpg',
    'Duckyo’s Leisure Life รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Duckyo’s Leisure Life' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240924_164239_862394____2_____1200x1200.jpg',
    'Duckyo’s Leisure Life รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Lord May King series' limit 1),
    'https://pbs.twimg.com/media/GcGZ-0xbAAAjufY.jpg',
    'Lord May King series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/2-22.png',
    'KUROMI Chess รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/3-18.png',
    'KUROMI Chess รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_160952_976182____1_____1200x1200.jpg',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_160952_967282____2_____1200x1200.jpg',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Superstar Dance Moves' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240807_141606_773835____1_____1200x1200.jpg',
    'Superstar Dance Moves รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Teletubbies Tinky Winky Trendy' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240924_101524_308933____5_____1200x1200.jpg',
    'Teletubbies Tinky Winky Trendy รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/1-44.png',
    'Doraemon: Concert series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/4-40.png',
    'Doraemon: Concert series รูปที่ 2',
    false,
    2
    ), ---- Atongshopp 玩具
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasg-m2ca8a7559r809.webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasd-m2c55tcluz1db7.webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasg-m2avit7zxzoh23.webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://down-th.img.susercontent.com/file/cn-11134207-7ras8-m1qpq86wnxh027.webp',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://down-th.img.susercontent.com/file/cn-11134207-7ras8-m1qpq84oprn1c0.webp',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://down-th.img.susercontent.com/file/cn-11134207-7ras8-m1qpq86wmiwk29.webp',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://www.thetoygalleria.com/cdn/shop/files/IMG-4618_600x.png?v=1729667712',
    'Sank-Good Night Series-Stellar Trail รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://www.thetoygalleria.com/cdn/shop/files/IMG-4616_600x.png?v=1729667712',
    'Sank-Good Night Series-Stellar Trail รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://www.thetoygalleria.com/cdn/shop/files/IMG-4617_600x.png?v=1729667712',
    'Sank-Good Night Series-Stellar Trail รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20241014_171520_379058____8_____1200x1200.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20241014_171521_776787____6_____1200x1200.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20241014_171520_897583____5_____1200x1200.jpg',
    'MOLLY carb - Lover Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    'https://pbs.twimg.com/media/F_2RQwWbgAAVJ5O?format=jpg&name=medium',
    'FORERUNNER Limited Blister card รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    'https://pbs.twimg.com/media/F_2RQwVasAAI0PA?format=jpg&name=medium',
    'FORERUNNER Limited Blister card รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rash-m0ydt1b8hprq7b.webp',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7ras8-m0ydt1b8lxsrec.webp',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasm-m0ydt1b8hq3f10.webp',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/5-44.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/3-47.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://www.figuresinstock.com/wp-content/uploads/2024/10/9-20.png',
    'BABY ZORAA - I’m the BOSS รูปที่ 3',
    false,
    3
    ), ---- PIECE Of JOY
    ((select product_id from products where name = 'จาน Rico ซีรี่ย์ 2' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r992-ls6u223oy7y5b5.jpg',
    'จาน Rico ซีรี่ย์ 2 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rask-m0fgwnpmrowo2d.jpg',
    'RICO Sweet Time รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98z-lydkteegcfjd59.jpg',
    'RICO Sweet Time รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rash-m0fgwjpwm0my37.jpg',
    'RICO Sweet Time รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'RICO Sweet Time' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98p-lydktd309v290d.jpg',
    'RICO Sweet Time รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98y-lrel1rweukj262.jpg',
    'RICO Happy Picnic Together รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98z-lwmriy4dvtfzcd.jpg',
    'RICO Happy Picnic Together รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'RICO Happy Picnic Together' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98v-lwmriy4dx80f69.jpg',
    'RICO Happy Picnic Together รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Baby Three V1' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7ras8-m0fsx4pzepqwa3.jpg',
    'Baby Three V1 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three V1' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasb-m0fsx68x6bi27f.jpg',
    'Baby Three V1 รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rase-m23d3eqt237tc1.jpg',
    'Baby Three Ocean รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasb-m0tucrlfhghm08.jpg',
    'Baby Three Ocean รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three Ocean' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r990-m0aet506c6agb1.jpg',
    'Baby Three Ocean รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasc-m0qxr9kcbpawae.jpg',
    'Baby Three V.3 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98u-lykm1grv1cq15c.jpg',
    'Baby Three V.3 รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Baby Three V.3' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98s-lykm1grv1coxfd.jpg',
    'Baby Three V.3 รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Maltese Hipper' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasj-m0wuu5100s4b0f.jpg',
    'Maltese Hipper รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ที่เปิดขวด babythree' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasd-m1s9l88lrzhlc7.jpg',
    'ที่เปิดขวด babythree รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ที่เปิดขวด babythree' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasl-m1s9l9de4b933f.jpg',
    'ที่เปิดขวด babythree รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98x-ltj6k08ph37jad.jpg',
    'Shinwoo Happy birthday รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98z-ltj6k08pfo7ccd.jpg',
    'Shinwoo Happy birthday รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Shinwoo Happy birthday' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98v-ltj6k08pfon3af.jpg',
    'Shinwoo Happy birthday รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'MEGA MOLLY SPACE V.3' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r990-lz4do58myqo1c6.jpg',
    'MEGA MOLLY SPACE V.3 รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'MEGA MOLLY SPACE V.3' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98q-lz4do6pwss6h3c.jpg',
    'MEGA MOLLY SPACE V.3 รูปที่ 2',
    false,
    2
    ), --- POP MART
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20240307_135855_545730__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20240307_135857_061608__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY × Powerpuff Girls Series Figures' limit 1),
    'https://prod-eurasian-res.popmart.com/default/20240307_135900_754875__1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY × Powerpuff Girls Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_213511_134868____2_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_213511_907057____3_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 1 limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_213511_222854____4_____1200x1200.jpg',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_212751_238975____2_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_212751_656307____3_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Plush Badge Blind Box' limit 1),
    'https://prod-thailand-res.popmart.com/default/20240930_212751_802037____4_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'CRYBABY Crying Again Series-Plush Badge Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    'https://global-static.popmart.com/globalAdmin/1730688588931____me-and-my-elephant-pal____.png?x-oss-process=image/format,webp',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    'https://global-static.popmart.com/globalAdmin/1730688577735____tuk-tuk-ahead-slow-down____.png?x-oss-process=image/format,webp',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    'https://global-static.popmart.com/globalAdmin/1730688566552____hello-thailand____.png?x-oss-process=image/format,webp',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box' limit 1),
    'https://global-static.popmart.com/globalAdmin/1730688557130____enjoying-tom-yum-soup____.png?x-oss-process=image/format,webp',
    'CRYBABY HELLO THAILAND SERIES-Mirror Pendant Blind Box Box รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    'https://prod-thailand-res.popmart.com/default/20241105_173934_617245____2_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    'https://prod-thailand-res.popmart.com/default/20241105_173934_421075____3_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    'https://prod-thailand-res.popmart.com/default/20241105_173934_555548____4_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 2 limit 1),
    'https://prod-thailand-res.popmart.com/default/20241105_173934_742450____5_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241106_103214_490715____2_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241106_103213_759841____3_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Disney Winnie the Pooh Gift Giving Series Figures' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241106_103213_133527____4_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'Disney Winnie the Pooh Gift Giving Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_114053_410085____2_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_114053_418239____3_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'BAZBON Label Plan Series 1/8 Action Figure' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_114053_225670____4_____1200x1200.jpg?x-oss-process=image/resize,p_30,format,webp,format,webp',
    'BAZBON Label Plan Series 1/8 Action Figure รูปที่ 3',
    false,
    3
    ), -----Gachabox
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98v-lvy924tp6ysweb.webp',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98p-lvy924tp8ddc8e.webp',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98v-lvy924tpdzn45a.webp',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Mr. Bone Mini 002 Time Travel Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98t-lvy924tpw98v2b.webp',
    'Mr. Bone Mini 002 Time Travel Series รูปที่ 4',
    false,
    4
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98o-lzd4knpuvv5tfb.webp',
    'Mr Bone Junior First Day Series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r98u-lzd4knpux9rd52.webp',
    'Mr Bone Junior First Day Series รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Mr Bone Junior First Day Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7r992-lzd4knpuugldc7.webp',
    'Mr Bone Junior First Day Series รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Hirono Mime Series Cable Iphone Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasg-m2ao7re1z2qsc2.webp',
    'Hirono Mime Series-Cable รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Hirono Mime Series Cable Iphone Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rask-m2ao7re1w9lwc2.webp',
    'Hirono Mime Series-Cable รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasc-m2ao0ceolcdd9f.webp',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasc-m2ao0ceomqxt9a.webp',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'POLAR - HELLO POLAR Season 1 Series Figures' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7ras8-m2ao0ceoo5i9da.webp',
    'POLAR - HELLO POLAR Season 1 Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rask-m2aonsld899d38.webp',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasm-m2aonsatnoptad.webp',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/th-11134207-7rasm-m2aonsbxm28xab.webp',
    'Neon Genesis Evangelion x WASA EVA 206 Series Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Bearbrick series 44 100% by Medicom Toy Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/d63cf1d73fe7f44ffb812c28b00537e6.webp',
    'Bearbrick series 44 100% by Medicom Toy Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Bearbrick series 44 100% by Medicom Toy Blind Box' limit 1),
    'https://down-th.img.susercontent.com/file/acb9ad2dd7c431823607b3f5508d6643.webp',
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