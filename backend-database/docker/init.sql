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
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t51.75761-15/465863233_17984151845716691_3247905783474066045_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeG8mKufnUeJK375tAOWir6l_T99qeVIjk79P32p5UiOTjJ7xB9QBL5ttpaS0H8Pw9monA1QrLvCsXgfelANk6ka&_nc_ohc=HUH31IA5HBwQ7kNvgE8R5EE&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=ABfhEELcaqisUSstM2ZtdWQ&oh=00_AYAxlHWmiVyAjfCvxZP_ucX1c70klvX9rP9LEFpEGXXDQw&oe=67325563',
    'Duckyo’s Leisure Life รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Duckyo’s Leisure Life' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t51.75761-15/466025997_17984151854716691_6273115569583305759_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFH9gvbh6otckm2fK1_7DYu9DJjyT0dguv0MmPJPR2C60SzidL6ZoYeLoTPfoteIsYHyxepX6AWPbMOvwat5p5_&_nc_ohc=l4t74k3mC9gQ7kNvgEpP8oA&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=ATITeVGv73ARH3F3yU8bwm4&oh=00_AYClunmf_JnJ4jjd6ZGZHSg0PiYixfiWx2dVe6TC6hd2Rw&oe=67324E85',
    'Duckyo’s Leisure Life รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Lord May King series' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t51.75761-15/465803670_17984046089716691_7210264324426134172_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeE8o7spa-hXTVvdNiwP2KsrbL5LxT-qei1svkvFP6p6LWF-o_09NcaJtcPZpZNmJIc4gKDBuWXGRgkRH8D9WjiZ&_nc_ohc=6R3be_PKQ90Q7kNvgF_tbAE&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=A_Pf0SajOrPdbbH-tf5SnwI&oh=00_AYAmE19BnaKrO_NXl7j5yRtxAKCv5umtyyazjzDQug9mgg&oe=67323AFD',
    'Lord May King series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    'https://scontent.fbkk7-2.fna.fbcdn.net/v/t51.75761-15/465811430_17983949759716691_8693819101049662006_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeF-pkLkVt-hVh62SXzLPFfrJY7XlPFif_cljteU8WJ_92rjjT3WKCFmLDRKYXFkxvljqozs8a7oQUmD9gSvsR69&_nc_ohc=WpdQ3JgyDEgQ7kNvgG26yEL&_nc_zt=23&_nc_ht=scontent.fbkk7-2.fna&_nc_gid=AheSQZqqFcssWv_gO_PrpZ-&oh=00_AYBoPvujfDUcpMt9M60lTgPrjyyXb-R2JZuAkY-pMk-9Qg&oe=67324C6A',
    'KUROMI Chess รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'KUROMI Chess' limit 1),
    'https://scontent.fbkk7-3.fna.fbcdn.net/v/t51.75761-15/465762073_17983949768716691_7404620138237766469_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeF8BdKlhSazDOgwhtRFItndmaOxW5kjDDGZo7FbmSMMMVsAnO9cudtMljKAoUGO_1jgUD6aVa_nZ6enkGe27pVQ&_nc_ohc=YqE0a9tZApoQ7kNvgHymTZi&_nc_zt=23&_nc_ht=scontent.fbkk7-3.fna&_nc_gid=AuvpnnAdmQx754cjyXFnqr1&oh=00_AYA_Xv4gSVtQkKhA-RRnN6Lzvp6D2v1TjA5G0Lm-pxC36Q&oe=67324401',
    'KUROMI Chess รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    'https://prod-thailand-res.popmart.com/default/20241022_160952_967282____2_____1200x1200.jpg',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'ANGEL IN CLOUDS Vinyl Face Doll' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t51.75761-15/465618796_17983926014716691_568781402531885017_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHSoyzgFWOw5_0zR1wfkdMKVRAUHp3s1RlVEBQenezVGbND5IplAUVXG2TuRNKmrSA19diBjKPfOD0HTT1aBhO8&_nc_ohc=UJKfQLq3ZkMQ7kNvgFE60qe&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=AdHfEng2bTSHilB6FVV318_&oh=00_AYDyT1-bRQ5IB-df7n0_bqqwDFfSD7ercZUE4krD62cMww&oe=67325B76',
    'ANGEL IN CLOUDS Vinyl Face Doll รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Superstar Dance Moves' limit 1),
    'https://scontent.fbkk7-2.fna.fbcdn.net/v/t39.30808-6/462469331_17980460834716691_2791268596996854742_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEkXXFVUwUfn5-EP7DyagOLxoE7GArLDm_GgTsYCssOb-LRnG7bATz-5JClnQGBLujKqX0TdhUyEQNM_hJmlcTa&_nc_ohc=fpwl9zNMip8Q7kNvgH6TLXy&_nc_zt=23&_nc_ht=scontent.fbkk7-2.fna&_nc_gid=ARjaUPV1xX9xCclqOfCwAJ0&oh=00_AYCoQ-XnbQek27hIx-Won9HtXS-pUywU0Rsoeky-nzEWow&oe=6732592B',
    'Superstar Dance Moves รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Teletubbies Tinky Winky Trendy' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/462319832_17980352192716691_4126062412104380924_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeF_w5uf3hynt2QHB6P31Cv5IDLVfiad6pQgMtV-Jp3qlFifxOpUT9H5SPjr5LtH2B1-QtR656EMOVUq14fJmPa0&_nc_ohc=JcaxrUkEv8AQ7kNvgGMSCNK&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=AFZ6XSUCuy5CFFcdty4-qg2&oh=00_AYAaUO9vNSYnsAZPiFUHPe0GWhm--ecXbOGfovkdgw-Lhg&oe=67325806',
    'Teletubbies Tinky Winky Trendy รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/461949139_17979835442716691_7674892299086863018_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEiHNNAHQWbt-MmFqc27WNukWs8bvTYU4KRazxu9NhTgkjngWk8rmF9PNRVoqyBS9LoYBnfmi092k8aUiCgD6uJ&_nc_ohc=6re-XNNM3D8Q7kNvgF0C0Bf&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=AhUVwl-KOUc7vyaCpt8PHnU&oh=00_AYD51w7rYcLqyyJABz038uDg6tLpoSvSWNZXXYo1Hm97Cw&oe=67323E9B',
    'Doraemon: Concert series รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Doraemon: Concert series' limit 1),
    'https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/461888187_17979835439716691_3173218792331576333_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeH3IKIWiUAy1JYXwS1DHhHeM90N9w9QMpUz3Q33D1AylSvzsyG6pw_OZfxk3S--EDhqpuDsF_pjQC8v6Vr2Z9sd&_nc_ohc=yqfA59H62vIQ7kNvgH5yi72&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=AVwQqzCB8P561uUT1yYEy8K&oh=00_AYCxLoAL8YL4hL2wEpzPD9EYbNq6z6yZxBT93t-982Pp4Q&oe=673240F6',
    'Doraemon: Concert series รูปที่ 2',
    false,
    2
    ), ---- Atongshopp 玩具
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/465763232_1120812770047338_7459509876060254854_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHLUppD_eeJ8Of24-FyFDtHplhbMfKzx6OmWFsx8rPHo2db5zPWRAmaBfFz3e2tGbWZVuhcRuYZIrRvtOrrnt11&_nc_ohc=6jNdGR4czowQ7kNvgEKK6iP&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=Aqwv51lcmcda-CU94Sc2G8U&oh=00_AYBGZ6TY_UdPxSrM-tyl-g6UKdVfuLw-RQVMh0TkLtCNPQ&oe=67326191',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/465816738_1120812886713993_402622318044967002_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHz89pu33bW7gFkVXy8eo5PLtAwDtAEiUgu0DAO0ASJSPyAQEkrGM1_GIE2eg5CurAzLp5BcjvESYrQCHciR07w&_nc_ohc=Odfi2Cbt5eEQ7kNvgFXiy56&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=Azv2uBMGkPW5-u6s667UG01&oh=00_AYCm4iDACFnw7rIQK-LSsfRL6Yo3VaqCDzehgEOqzh9X8A&oe=67325AB2',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'SKULLPANDA Tell Me What You Want Series Figures' and category_id = 1 limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/465779042_1120813080047307_4029007466859585481_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEF00Z-pmD-6KxjTyi5STAtdmTSF412SQJ2ZNIXjXZJAttmaj25uoCBt_eE_Eb90B0Onls-EMxIUuN140KmYFDo&_nc_ohc=R5EVcJU_wMYQ7kNvgF_edOw&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=Aeoh8oJmUWYZKXmuGYIU2n4&oh=00_AYD7x3PWEmhfFswhHN_X-6NlGjoq8yuvOyOcSzy09-GVow&oe=67325A23',
    'SKULLPANDA Tell Me What You Want Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/464482245_1112306420897973_6928155803215777340_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHdzeWdx6xSKVNU3XVN9T7wPEGJBh_Q6SU8QYkGH9DpJT9knsEuX3KdwajsXMA266q2wo7nHI2Kijg3_MpZLG-D&_nc_ohc=S09JrmDwfzkQ7kNvgHYP_A3&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=AMsZUUMEpuVsAwlP4EV7FND&oh=00_AYCEgLugQgRLyyXOoDZvbzETQQPRnaAXgJ_1iSqPc3KQ0Q&oe=67323DA4',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/464612852_1112306720897943_685820996009581585_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGQmap9bzd7ge_ISnDCc6bviRZLSMUbenOJFktIxRt6c5483s0nLTLiOHRvkaiojVVi0Z1egyr2vl9fa-4oPVnt&_nc_ohc=cztLm_0gvOcQ7kNvgFXAtgK&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=AYhiU-eQwr0XHzt3wGdgThS&oh=00_AYDPIJ96ZREKZNaitcwjIPCJkEqc-L4H6qHgDCHquy1uqA&oe=67323461',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Hirono×Le Petit Prince Series Blind Box Figures' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/464665615_1112306780897937_4227147454944656218_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEixAa-xIhFu54gxE90iI_AY2VYN5GAMDtjZVg3kYAwOz9SpxB1N3r9yBiQZkZx0D4lVErtMT9KD402dYm-PIct&_nc_ohc=tyrzeWjegQEQ7kNvgH8c4nC&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=Ai3HMqmGE7GokPPpfGwKWh0&oh=00_AYBJW4l6YHzqmCx0MY2qJVXgOFVdzGQyr232w_U0AJaz6Q&oe=67325ADA',
    'Hirono×Le Petit Prince Series Blind Box Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/464315521_1110625674399381_6925599719895618962_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEPpseCBWkHx7nPIF7M5sIfw-XfcrK55szD5d9ysrnmzIiDARX7t6WNLGXfzaCR0XjiRmc6Jj_0ci9dWXMXJFj0&_nc_ohc=mRDeap6AyB8Q7kNvgHpUGlg&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=A3Z9uP5PfAPkEeQsUdy3bpl&oh=00_AYBeGBBCmhjYgzJgaTMvwreI16Skky7GrmIxRDdJHAHElw&oe=673249FF',
    'Sank-Good Night Series-Stellar Trail รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/464303787_1110626911065924_6979102509674068891_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEHsFmWgEOzIYxMsAXiRHPm4Md3AT8FQzvgx3cBPwVDO04hS_iUz3vxZJHdy0qZADk7HmT7H2hT7YGc0O4hy2kK&_nc_ohc=b8l1N4GQy14Q7kNvgEDj4dQ&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=AdDNaqm7n-g7unPF38jslfG&oh=00_AYDn26XUwDy-GDEwtWfLev3Y2wZjwEi1PWPP3CvpXOVsJA&oe=6732527B',
    'Sank-Good Night Series-Stellar Trail รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'Sank-Good Night Series-Stellar Trail' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/464323873_1110626937732588_5274894543232205349_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGNPHQxJKgFPrToBPUIVXpJn_wBx_WvmXuf_AHH9a-Ze-VATGAW8Eg6qXlqd_zqjWuKqi7aTYrdXfiOxdBqO277&_nc_ohc=CTi4iCMFVb8Q7kNvgG-K-JG&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=A38Qd6frwhiSSWp0q3tah4V&oh=00_AYCy5lUbsrghJgg6VoZIcVkdaeelVZjJCn7MUxtuCf0lIw&oe=673259F3',
    'Sank-Good Night Series-Stellar Trail รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/463319946_1103827185079230_8688593301227689922_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFbSjTSWz_QQl7QmDCf8-sHe7scMEmiHmh7uxwwSaIeaMqvhxznEGRdb1Wv5DZIHTm4Sdj4_stTuYZg40iTy0QF&_nc_ohc=YXWkgmjbc74Q7kNvgEvaiMC&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=Ag2UAlVCdB0Fm7DazEAbcPE&oh=00_AYCBHehBazMFX8YsxlEYU6dRwIXKjeqOzhzvFvSxLSJ_qQ&oe=67324511',
    'MOLLY carb - Lover Series Figures รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/463338093_1103827165079232_8487848431591608065_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeHx4kphdjYIYpW-7TKzQItBwUYNGXOr5s3BRg0Zc6vmzbhFDEAr7UPWpdTY6JLUs73OEatQJtw3-RGyCP8LYI9Y&_nc_ohc=y61MsILwatUQ7kNvgEwlue1&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=AEheUWaaPeY1ZoM5kji6iHT&oh=00_AYCV2vfkgPGVLIO6MPV0ODwWcauKQRylHFqZ7LMNLDOPTw&oe=67325633',
    'MOLLY carb - Lover Series Figures รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'MOLLY carb - Lover Series Figures' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/463400297_1103827318412550_5210525345657501126_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeH2pH7Ns9bvwMw547Afa1H2q-9bSg_MyDOr71tKD8zIM4WuiG2VJ45uM4_MNAEednLKMMqeAOWTXlM4eHKU_-W7&_nc_ohc=hgwuQMqGPeMQ7kNvgHhGLRm&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=Aw35KG3xJt70c0Z-BUp-vWh&oh=00_AYDkg1wo20HTwzUVA-_OC5XbqH5G67C6vEU8LB4x3ZnenA&oe=67323BDF',
    'MOLLY carb - Lover Series Figures รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/462511489_1098454055616543_1996745685480113756_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFlB-ukUwshA-PlXBQWz8h75W5PJJyCx2Hlbk8knILHYa5dOtY66T69dQqh5huf32IBFgrONef-Q3s2A0dowONh&_nc_ohc=Hc3tHfAselgQ7kNvgEr9HW6&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=A1zNRZs98mq-j_w0Nvp-N72&oh=00_AYDyilVvuXzdjkqMFoyOxHcd90M0HJ7E6tjdB0iadHSYUw&oe=673245F1',
    'FORERUNNER Limited Blister card รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/462624428_1098453792283236_8160291559295175797_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeH9txfCw1INTOyPhxj__XeHZG-S5pWs1v9kb5LmlazW_z3o_IFvRRb6mWpCJ5wDGLpkPpf_9GWPw35tauYI09TV&_nc_ohc=zWZL75o0nzwQ7kNvgEOgtJR&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=ADAkdVkxM6tTdNQfwoonQ0z&oh=00_AYA7TBXG2YJvTsH9_kLBwwFl7ucVkNGp6xFVdZiBy_V_-g&oe=6732416B',
    'FORERUNNER Limited Blister card รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'FORERUNNER Limited Blister card' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/462458283_1098453772283238_3753974709171004376_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGqKLNIvfvMJGTVY7fE2gDOjxwRgiYrfKWPHBGCJit8pfI8deLG30ywQjnzt69IwDJiPF33QTS1IlOcm9vqb-Ll&_nc_ohc=fCKRdS2M3xUQ7kNvgE5kwWo&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=Ad3bWWkDagqC6g_Vw1Tz3MF&oh=00_AYDcBhldhP0CduM6WKd1poxtIuPFy_-5V4tL08dPqhUJ8g&oe=673252B6',
    'FORERUNNER Limited Blister card รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/462060768_1094448712683744_8109779179481646928_n.jpg?stp=dst-jpg_s600x600&_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFVWIiaij5ks02DbYy_qZoSNkwGEPTXwq82TAYQ9NfCr0hwpp9RJWvvM6cpWMe9LESQ7fwUlLegc-WKBTGxZ682&_nc_ohc=zJU1LtvxWpoQ7kNvgFzfdwi&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=AiUcjrTGDpUzf5747vfm9Pe&oh=00_AYBSl-_1H5pSgOKgRN5SgJ4pivZmdZr31VQZo0n7pJHV9A&oe=67324672',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/462091860_1094448709350411_5587284207355317049_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEuwLZYzYhzj29Yb3U_RUvdPDzkglrlFCI8POSCWuUUImUd9P_dSGsYCRtJdXHjawDl7xWdtJgtY3CXRKHOByZT&_nc_ohc=MnZ5CgsjF0wQ7kNvgHVGTh2&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=Asf7PUe8fAf0zJavsFToC6n&oh=00_AYBHp2rMjblWFx-gDC0FSyNi4wXOUD1lR1QiuF735ftB9A&oe=673245FE',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'CRYBABY Crying Again Series-Card Holder Blind Box' and category_id = 2 limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/462140597_1094448732683742_8242414332485510079_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeGCUckDVUIQFnqOvEulumQKzPYV928jghPM9hX3byOCE2UvLEoPWHoy6gvnJeJkJOjlqQcHdT6C-Zl99tmY2-f7&_nc_ohc=dDpjnV7wMSIQ7kNvgGc-KU-&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=A2Jy8-OxsmRPJ0GiBg8gr0q&oh=00_AYChJLWPprJPvRamVkHTm-8bMZ4HwB19teJFRbEHRTcOYg&oe=67323B43',
    'CRYBABY Crying Again Series-Card Holder Blind Box รูปที่ 3',
    false,
    3
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://scontent.fbkk2-8.fna.fbcdn.net/v/t39.30808-6/461941782_1094411686020780_8202070772120704675_n.jpg?stp=dst-jpg_s600x600&_nc_cat=100&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFUeaxi0w6kAzUaWKNyu7zCkpT004F7Z1SSlPTTgXtnVJQzjjUJyYMxmi5piRIFXCzxhfo0FV-Pvo0PxhWh4hCq&_nc_ohc=APsvzZFHsnsQ7kNvgGZizOd&_nc_zt=23&_nc_ht=scontent.fbkk2-8.fna&_nc_gid=AWmeCNyZ4WlNrTe53Li6AEo&oh=00_AYDdbWDUBhaujOQeU0uFCDoF46ITQBXWiGqlvm5Zju-9yg&oe=67324E83',
    'BABY ZORAA - I’m the BOSS รูปที่ 1',
    true,
    1
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/462140806_1094411696020779_4419543353892178039_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeH-AtbwcYdci5YRwbpnHqTjHDtztqA-QmIcO3O2oD5CYh1oBMVeb7x0HldRwjLZR7O9G_gyMy0uMD9Ax0Lkk_9b&_nc_ohc=FANxq_oZ0RgQ7kNvgE4YVKc&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=AjKdsuOSHnmJc0yglgidIo_&oh=00_AYDAZWej73DSU3X0Qgzqfm_5M4tiwY6jbEvw4Ad0_tn7QA&oe=6732679F',
    'BABY ZORAA - I’m the BOSS รูปที่ 2',
    false,
    2
    ),
    ((select product_id from products where name = 'BABY ZORAA - I’m the BOSS' limit 1),
    'https://scontent.fbkk2-7.fna.fbcdn.net/v/t39.30808-6/462142548_1094411626020786_2886727740669605329_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeFCu9fcoQYq2-8STCO6A6K7JIDoO7eJLDMkgOg7t4ksM1PMjtMxI4g3FA9Ok62ftJ6X5MUo02ascOyBkKj0wzJe&_nc_ohc=GIXZcubtS8wQ7kNvgG6u-_s&_nc_zt=23&_nc_ht=scontent.fbkk2-7.fna&_nc_gid=A0fqc2XutjjNX23-V1lWnaZ&oh=00_AYCrujOuz9hA3c95apJASALprdj7uzO3eqEWY292OaWAYg&oe=67326B6E',
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